class V1::DraftsController < V1::V1Controller
  include PaginationHelper

  api :GET, '/drafts', 'Returns a list of draft publications created or updated by current user'
  def index
    publications = Publication.where(deleted_at: nil).where(published_at: nil)
    user_publication_ids = PublicationVersion.
      where('created_by = (?) or updated_by = (?)',
            @current_user.username, @current_user.username).
            select(:publication_id)
    publications = publications.where(id: user_publication_ids).where(process_state: "DRAFT")

    # ------------------------------------------------------------ #
    # PAGINATION BLOCK START
    # ------------------------------------------------------------ #
    @response = generic_pagination(resource: publications, resource_name: 'publications', page: params[:page], additional_order: "updated_at desc", options: {include_authors: true, brief: true})

    render_json(200)
  end

  api :POST, '/drafts', 'Creates a new publication, and returns the created object'
  def create
    params[:publication] = {} if !params[:publication]

    params[:publication][:created_by] = @current_user.username
    params[:publication][:updated_by] = @current_user.username

    if params[:publication][:xml]
      params[:publication][:xml] = params[:publication][:xml].strip
    end

    create_basic_data
    Publication.transaction do
      begin
        pub = Publication.build_new(permitted_params(params))
        if pub.save_new
          @response[:publication] = pub.as_json
        else
          raise (V1::ControllerError.new(
            code: ErrorCodes::VALIDATION_ERROR,
            errors: { publication: pub.errors.values },
          ))
        end
        create_publication_identifiers!(publication_version: pub.current_version)
        create_publication_links!(publication_version: pub.current_version)
      rescue V1::ControllerError => error
        message = error.message.present? ? error.message : "#{I18n.t "publications.errors.create_error"}"
        error_msg(error.code, message, error.errors)
        render_json
        raise ActiveRecord::Rollback
      end
      render_json(201)
    end
  end

  api :PUT, '/drafts/:id', 'Updates any value of a publication object'
  desc "Used for updating a publication object which is not yet published (draft)"
  def update
    id = params[:id]
    publication = Publication.find_by_id(id)
    if publication
      publication_version_old = publication.current_version
      params[:publication] = publication.attributes_indifferent.merge(params[:publication])
      params[:publication][:created_by] = publication_version_old.created_by
      params[:publication][:updated_by] = @current_user.username
      params[:publication][:process_state] = "DRAFT"

      if params[:publication][:epub_ahead_of_print]
        publication.epub_ahead_of_print = DateTime.now
      else
        publication.epub_ahead_of_print = nil
      end

      Publication.transaction do
        if !params[:publication][:publication_type_id]
          #TODO: Errors are unhandled here??
          publication_version_new = publication.build_version(permitted_params(params))
        else
          publication_type = PublicationType.find_by_id(params[:publication][:publication_type_id])
          if publication_type.present?
            publication_version_new = publication.build_version(publication_type_permitted_params(publication_type: publication_type, params: params))
          else
            raise (V1::ControllerError.new(
              code: ErrorCodes::VALIDATION_ERROR,
              message: "#{I18n.t "publications.errors.unknown_publication_type"}: #{params[:publication][:publication_type]}"
            ))
          end
        end
        publication_version_new.author = params[:publication][:authors]
        # Return record instead would be nice?
        if publication.save_version(version: publication_version_new, process_state: "DRAFT")
          # TODO: Standardize error handing, right now very inconsistent
          begin
            if params[:publication][:authors].present?
              params[:publication][:authors].each_with_index do |author, index|
                create_affiliation!(publication_version_id: publication_version_new.id, person: author, position: index+1)
              end
            end

            if params[:publication][:project].present?
              params[:publication][:project].each do |project|
                record = Projects2publication.create(publication_version_id: publication_version_new.id, project_id: project)
                if record.errors.any?
                  raise (V1::ControllerError.new(
                    code: ErrorCodes::VALIDATION_ERROR,
                    errors: { project: record.errors.values }
                  ))
                end
              end
            end

            if params[:publication][:series].present?
              params[:publication][:series].each do |serie|
                record = Series2publication.create(publication_version_id: publication_version_new.id, serie_id: serie)
                if record.errors.any?
                  raise (V1::ControllerError.new(
                    code: ErrorCodes::VALIDATION_ERROR,
                    errors: { series: record.errors.values }
                  ))
                end
              end
            end

            if params[:publication][:category_hsv_local].present?
              params[:publication][:category_hsv_local].each do |category|
                record = Categories2publication.create(publication_version_id: publication_version_new.id, category_id: category)
                if record.errors.any?
                  raise (V1::ControllerError.new(
                    code: ErrorCodes::VALIDATION_ERROR,
                    errors: { category_hsv_local: record.errors.values }
                  ))
                end
              end
            end
            create_publication_identifiers!(publication_version: publication_version_new)
            create_publication_links!(publication_version: publication_version_new)
          rescue V1::ControllerError => error
            # @TODO: should not be ...errors.update_error?
            message = error.message.present? ? error.message : "#{I18n.t "publications.errors.create_error"}"
            error_msg(error.code, message, error.errors)
            render_json
            raise ActiveRecord::Rollback
          end

          @response[:publication] = publication.as_json
          @response[:publication][:authors] = people_for_publication(publication_version_id: publication_version_new.id)
          if publication_version_new.datasource
            ImportManager.feedback_to_adapter(
              datasource: publication_version_new.datasource,
              sourceid: publication_version_new.sourceid,
              feedback_hash: {publication_id: publication.id})
          end
          render_json(200)
        else
          error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "publications.errors.update_error"}", publication.errors)
          render_json
          raise ActiveRecord::Rollback
        end
      end
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "publications.errors.not_found"}: #{params[:id]}")
      render_json
    end
  end

  api :DELETE, '/drafts/:id'
  desc 'Deletes a given publication based on id. Only effective on draft publications.'
  def destroy
    id = params[:id]
    publication = Publication.find_by_id(id)

    if !publication.present?
      error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "publications.errors.not_found"}: #{params[:id]}")
      render_json
      return
    end

    if !publication.is_draft?
      error_msg(ErrorCodes::PERMISSION_ERROR, "#{I18n.t "publications.errors.cannot_delete_published"}")
      render_json
      return
    end

    if publication.update_attribute(:deleted_at, DateTime.now)
      render_json
    else
      error_msg(ErrorCodes::VALIDATION_ERROR,"#{I18n.t "publications.errors.delete_error"}: #{params[:id]}")
      render_json
    end
  end

  private

  def permitted_params(params)
    field_list = Field.all.pluck(:name) + global_params
    field_list.delete("epub_ahead_of_print")
    field_list.delete(:epub_ahead_of_print)
    params.require(:publication).permit(field_list)
  end

  def publication_type_permitted_params(publication_type:, params:)
    field_list = publication_type.fields.pluck(:name) + global_params
    field_list.delete("epub_ahead_of_print")
    field_list.delete(:epub_ahead_of_print)
    params.require(:publication).permit(field_list)
  end


  # Params which are not defined by publication type
  def global_params
    [:publication_type_id, :is_draft, :is_deleted, :created_at, :created_by, :updated_by, :biblreviewed_at, :biblreviewed_by, :bibl_review_postponed_until, :bibl_review_postpone_comment, :content_type, :xml, :datasource, :sourceid, :ref_value]
  end

  def create_basic_data
    params[:publication][:deleted_at] = nil
    params[:publication][:publication_type] = nil
    params[:publication][:publanguage] ||= 'en'
  end

  def create_publication_identifiers!(publication_version:)
    if params[:publication][:publication_identifiers]
      params[:publication][:publication_identifiers].each do |publication_identifier|
        publication_identifier[:publication_version_id] = publication_version.id
        pi = PublicationIdentifier.create(
          publication_identifier_permitted_params(
            ActionController::Parameters.new(
              publication_identifier: publication_identifier
            )
          )
        )
        if pi.errors.any?
          raise (V1::ControllerError.new(
            code: ErrorCodes::VALIDATION_ERROR,
            errors: { publication_identifiers: pi.errors.values },
            message: "#{I18n.t "publication_identifiers.errors.create_error"}"
          ))
        end
      end
    end
  end

  def publication_identifier_permitted_params(params)
    params.require(:publication_identifier).permit(:publication_version_id, :identifier_code, :identifier_value)
  end

  def create_publication_links!(publication_version:)
    if params[:publication][:publication_links].present?
      params[:publication][:publication_links].each do |publication_link|
      #@TODO: if not params[:publication][:publication_links].kind_of?(Array) #respond_to?('each') #trow exception
        publication_link[:publication_version_id] = publication_version.id
        p publication_link
        #TODO: publication_version.create_publication_link
        pl = PublicationLink.create(
          publication_link_permitted_params(
            ActionController::Parameters.new(publication_link: publication_link)
          )
        )
        if pl.errors.any?
          raise (V1::ControllerError.new(
            code: ErrorCodes::VALIDATION_ERROR,
            errors: { publication_links: pl.errors.values },
            message: "#{I18n.t "publication_links.errors.create_error"}"
          ))
        end
      end
    end
  end

  def publication_link_permitted_params(params)
    params.require(:publication_link).permit(:url, :position, :publication_version_id)
  end

  # Creates connections between people, departments and publications for a publication and a people array
  def create_affiliation!(publication_version_id:, person:, position:, reviewed_at: nil, reviewed_publication_version_id: nil)
    p2p = People2publication.create({
      publication_version_id: publication_version_id,
      person_id: person[:id],
      position: position,
      reviewed_at: reviewed_at,
      reviewed_publication_version_id: reviewed_publication_version_id
    })
    if p2p.errors.any?
      raise (V1::ControllerError.new(
        code: ErrorCodes::VALIDATION_ERROR,
        errors: { authors: p2p.errors.values }
      ))
    end
    if person[:departments].present?
      person[:departments].each.with_index do |department, j|
        d2p2p = Departments2people2publication.create({people2publication_id: p2p.id, department_id: department[:id], position: j + 1})
        if d2p2p.errors.any?
          raise (V1::ControllerError.new(
            code: ErrorCodes::VALIDATION_ERROR,
            errors: { authors: d2p2p.errors.values }
          ))
        end
      end
    end
  end

  # Returns collection of people including departments for a specific Publication
  def people_for_publication(publication_version_id:)
    p2ps = People2publication.where(publication_version_id: publication_version_id).order(position: :asc)
    people = p2ps.map do |p2p|
      person = Person.where(id: p2p.person_id).first.as_json
      department_ids = Departments2people2publication.where(people2publication_id: p2p.id).order(updated_at: :desc).select(:department_id)

      departments = Department.where(id: department_ids)
      person['departments'] = departments.as_json

      presentation_string = Person.where(id: p2p.person_id).first.presentation_string(departments.map{|d| I18n.locale == :en ? d.name_en : d.name_sv}.uniq[0..1])
      person['presentation_string'] = presentation_string

      person
    end

    return people
  end

end

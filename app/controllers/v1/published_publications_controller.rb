class V1::PublishedPublicationsController < V1::V1Controller
  include PaginationHelper

  api :GET, '/published_publications', 'Returns a list of published publications based on filter parameters' 
  def index
    # Initialize filter parameters
    actor = params[:actor]
    registrator = params[:registrator]
    
    # If no parameters are given, default to setting actor as current_user
    if actor.nil? && registrator.nil?
      actor = 'logged_in_user'
    end

    publications = Publication.all

    if actor == 'logged_in_user'
      if @current_user.person_ids
        publications = publications.where('current_version_id in (?)', People2publication.where('person_id IN (?)', @current_user.person_ids).map { |p| p.publication_version_id}).where.not(published_at: nil).where(deleted_at: nil) 
      else
        publications = Publication.none
      end

    end

    if registrator == 'logged_in_user'
      publications = publications.where('current_version_id in (?)', PublicationVersion.where('created_by = (?) or updated_by = (?)', @current_user.username, @current_user.username).map { |p| p.id}).where.not(published_at: nil).where(deleted_at: nil)
    end

    @response = generic_pagination(resource: publications, resource_name: 'publications', page: params[:page])
    render_json(200)
  end

  api :POST, '/published_publications', 'Creates a published publication based on a draft object'
  def create
    draft_id = params[:publication][:draft_id]
    if draft_id
      publication = Publication.find_by_id(draft_id)
      if publication
        if publication.is_draft? || publication.is_predraft?
          publication.published_at = DateTime.now
          publish_publication(publication: publication)
        else
          error_msg(ErrorCodes::OBJECT_ERROR, "Publication with id #{draft_id} is not a draft")
          render_json
          return
        end
      else
        error_msg(ErrorCodes::OBJECT_ERROR, "Draft with id #{draft_id} does not exist")
        render_json
        return
      end
    else
      error_msg(ErrorCodes::REQUEST_ERROR, "No draft_id has been given")
      render_json
      return
    end
  end

  api :PUT, '/published_publications/:id', 'Updates a published publication'
  def update
    id = params[:id]
    publication = Publication.find_by_id(id)
    if publication
      if publication.is_published?
        publish_publication(publication: publication)
      else
        error_msg(ErrorCodes::OBJECT_ERROR, "Publication with id #{id} has not been published yet")
        render_json
        return
      end
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "Could not find publication with id #{id}")
      render_json
      return
    end
  end

  private
  def publish_publication(publication:)

    if publication
      publication_version_old = publication.current_version
      params[:publication] = publication.attributes_indifferent.merge(params[:publication])
      params[:publication][:created_by] = publication_version_old.created_by
      params[:publication][:updated_by] = @current_user.username
      
      # Reset the bibl review info
      params[:publication][:biblreviewed_at] = nil
      params[:publication][:biblreviewed_by] = nil
      params[:publication][:biblreview_postponed_until] = DateTime.now
      params[:publication][:biblreview_postpone_comment] = nil

      if params[:publication][:epub_ahead_of_print]
        publication.epub_ahead_of_print = DateTime.now
      else 
        publication.epub_ahead_of_print = nil
      end

      Publication.transaction do
        if !params[:publication][:publication_type_id]
          publication_version_new = publication.build_version(permitted_params(params))
        else
          publication_type = PublicationType.find_by_id(params[:publication][:publication_type_id])
          if publication_type.present?
            publication_version_new = publication.build_version(publication_type_permitted_params(publication_type: publication_type, params: params))
          else
            error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "publications.errors.unknown_publication_type"}: #{params[:publication][:publication_type]}")
            render_json
            raise ActiveRecord::Rollback
          end
        end
        publication_version_new.author = params[:publication][:authors]

        if publication.save_version(version: publication_version_new)
          if params[:publication][:authors].present?
            params[:publication][:authors].each_with_index do |author, index|
              oldp2p = People2publication.where(person_id: author[:id], publication_version_id: publication_version_old.id).first
              new_reviewed_at = nil
              new_reviewed_publication_version_id = publication_version_new.id
              if oldp2p
                new_reviewed_at = oldp2p.reviewed_at

                reviewed_p2p = nil
                # If last review date is nil and review has occured before, set review date to previous review date.
                if oldp2p.reviewed_at.nil? && oldp2p.reviewed_publication_version_id.present?
                  reviewed_p2p = People2publication.where(person_id: author[:id], publication_version_id: oldp2p.reviewed_publication_version_id).first
                  new_reviewed_at = reviewed_p2p.reviewed_at
                end
                if oldp2p.reviewed_publication_version_id.present?
                  # Check if publication object is different
                  if publication_version_new.review_diff(oldp2p.reviewed_publication_version).present?
                    new_reviewed_at = nil
                    new_reviewed_publication_version_id = oldp2p.reviewed_publication_version_id
                  end

                  # Use revewd_p2p if it exists, otherwise use oldp2p for comparison
                  p2p_to_compare_with = oldp2p
                  if reviewed_p2p.present?
                    p2p_to_compare_with = reviewed_p2p
                  end

                  # Check if affiliations are different
                  if p2p_to_compare_with.departments2people2publications.blank? || author[:departments].blank?
                    new_reviewed_at = nil
                    new_reviewed_publication_version_id = oldp2p.reviewed_publication_version_id
                  else
                    old_affiliations = p2p_to_compare_with.departments2people2publications.map {|x| x.department_id}
                    new_affiliations = author[:departments].map {|x| x[:id].to_i}
                    unless (old_affiliations & new_affiliations == old_affiliations) && (new_affiliations & old_affiliations == new_affiliations)
                      new_reviewed_at = nil
                      new_reviewed_publication_version_id = oldp2p.reviewed_publication_version_id
                    end
                  end
                end
              end
            create_affiliation(publication_version_id: publication_version_new.id, person: author, position: index+1, reviewed_at: new_reviewed_at, reviewed_publication_version_id: new_reviewed_publication_version_id)
            end
          end

          if params[:publication][:project].present?
            params[:publication][:project].each do |project|
              Projects2publication.create(publication_version_id: publication_version_new.id, project_id: project)
            end
          end

          if params[:publication][:series].present?
            params[:publication][:series].each do |serie|
              Series2publication.create(publication_version_id: publication_version_new.id, serie_id: serie)
            end
          end

          if params[:publication][:category_hsv_local].present?
            params[:publication][:category_hsv_local].each do |category|
              Categories2publication.create(publication_version_id: publication_version_new.id, category_id: category)
            end
          end

          create_publication_identifiers(publication_version: publication_version_new)
          
          @response[:publication] = publication.as_json
          @response[:publication][:authors] = people_for_publication(publication_version_id: publication_version_new.id)
          
          PublicationSearchEngine.update_search_engine(publication)
          render_json(200)
        else
          error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "publications.errors.publish_error"}", publication.errors)
          render_json
          raise ActiveRecord::Rollback
        end
      end
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "publications.errors.not_found"}: #{params[:id]}")
      render_json
    end
  end

  def publication_identifier_permitted_params(params)
    params.require(:publication_identifier).permit(:publication_version_id, :identifier_code, :identifier_value)
  end

  def create_publication_identifiers(publication_version: publication_version)
    if params[:publication][:publication_identifiers]
      pis_errors = []
      params[:publication][:publication_identifiers].each do |publication_identifier|
        publication_identifier[:publication_version_id] = publication_version.id
        pi = PublicationIdentifier.new(publication_identifier_permitted_params(ActionController::Parameters.new(publication_identifier: publication_identifier)))
        if !pi.save
          pis_errors << [pi.errors]
        end
      end
      if !pis_errors.empty?
        error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "publication_identifiers.errors.create_error"}", pis_errors)
        error = true
        raise ActiveRecord::Rollback
      end
    end 

  end

  def permitted_params(params)
    permitted_fields = Field.all.pluck(:name) + global_params
    permitted_fields.delete("epub_ahead_of_print")
    permitted_fields.delete(:epub_ahead_of_print)
    params.require(:publication).permit(permitted_fields)
  end

  def publication_type_permitted_params(publication_type:, params:)
    permitted_fields = publication_type.permitted_fields + global_params
    permitted_fields.delete("epub_ahead_of_print")
    permitted_fields.delete(:epub_ahead_of_print)
    params.require(:publication).permit(permitted_fields)
  end

  # Params which are not defined by publication type
  def global_params
    [:publication_type_id, :is_draft, :is_deleted, :created_at, :created_by, :updated_by, :biblreviewed_at, :biblreviewed_by, :bibl_review_postponed_until, :bibl_review_postpone_comment, :content_type, :xml, :datasource, :sourceid, :ref_value]
  end

  # Creates connections between people, departments and mpublications for a publication and a people array
  def create_affiliation (publication_version_id:, person:, position:, reviewed_at: nil, reviewed_publication_version_id: nil)
    p2p = {person_id: person[:id], position: position, departments2people2publications: person[:departments]}
    p2p_obj = People2publication.create({publication_version_id: publication_version_id, person_id: p2p[:person_id], position: position, reviewed_at: reviewed_at, reviewed_publication_version_id: reviewed_publication_version_id})
    department_list = p2p[:departments2people2publications]
    if department_list.present?
      department_list.each.with_index do |d2p2p, j|
        Departments2people2publication.create({people2publication_id: p2p_obj.id, department_id: d2p2p[:id], position: j + 1})
        # Set affiliated flag to true when a person gets a connection to a department.
        Person.find_by_id(person[:id]).update_attribute(:affiliated, true)
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

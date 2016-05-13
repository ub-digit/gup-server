class V1::DraftsController < V1::V1Controller
  #include PublicationsControllerHelper

  api :GET, '/drafts', 'Returns a list of draft publications created or updated by current user'
  def index
    publications = Publication.where(deleted_at: nil).where(published_at: nil)
    user_publication_ids = PublicationVersion.
      where('created_by = (?) or updated_by = (?)', 
            @current_user.username, @current_user.username).
            select(:publication_id)
    publications = publications.where(id: user_publication_ids)

    # ------------------------------------------------------------ #
    # PAGINATION BLOCK START
    # ------------------------------------------------------------ #
    pagination = {}
    metaquery = {}
    per_page = 30
    #metaquery[:query] = params[:query] # Not implemented yet

    metaquery[:total] = publications.count
    if !publications.empty?
      tmp = publications.paginate(page: params[:page], per_page:per_page)
      if tmp.current_page > tmp.total_pages
        publications = publications.paginate(page: 1, per_page:per_page)
      else
        publications = tmp
      end
      publications = publications.order(:id).reverse_order
      pagination[:pages] = publications.total_pages
      pagination[:page] = publications.current_page
      pagination[:next] = publications.next_page
      pagination[:previous] = publications.previous_page
      pagination[:per_page] = publications.per_page
    else
      pagination[:pages] = 0
      pagination[:page] = 0
      pagination[:next] = nil
      pagination[:previous] = nil
      pagination[:per_page] = nil
    end

    @response[:meta] = {query: metaquery, pagination: pagination}
    # ------------------------------------------------------------ #
    # PAGINATION BLOCK END
    # ------------------------------------------------------------ #

    @response[:publications] = publications
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

    error = false
    create_basic_data
    Publication.transaction do
      pub = Publication.build_new(permitted_params(params))
      if pub.save_new
        @response[:publication] = pub.as_json
      else
        error = true
        error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "publications.errors.create_error"}", pub.errors)
        render_json
        raise ActiveRecord::Rollback
      end
      create_publication_identifiers(publication_version: pub.current_version)
    end
    render_json(201) unless error.present?
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

      Publication.transaction do
        if !params[:publication][:publication_type]
          publication_version_new = publication.build_version(permitted_params(params))
        else
          publication_type = PublicationType.find_by_code(params[:publication][:publication_type])
          if publication_type.present?
            publication_version_new = publication.build_version(publication_type.permitted_params(params, global_params))
          else
            error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "publications.errors.unknown_publication_type"}: #{params[:publication][:publication_type]}")
            render_json
            raise ActiveRecord::Rollback
          end
        end
        publication_version_new.new_authors = params[:publication][:authors]
        if publication.save_version(version: publication_version_new)
          if params[:publication][:authors].present?
            params[:publication][:authors].each_with_index do |author, index|
              create_affiliation(publication_version_id: publication_version_new.id, person: author, position: index+1)
            end
          end

          if params[:publication][:project].present?
            params[:publication][:project].each do |project|
              Projects2publication.create(publication_version_id: publication_version_new.id, project_id: project)
            end
          end

          create_publication_identifiers(publication_version: publication_version_new)

          @response[:publication] = publication.as_json
          @response[:publication][:authors] = people_for_publication(publication_version_id: publication_version_new.id)
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
    params.require(:publication).permit(PublicationType.get_all_fields + global_params)
  end

  # Params which are not defined by publication type
  def global_params
    [:publication_type, :is_draft, :is_deleted, :created_at, :created_by, :updated_by, :biblreviewed_at, :biblreviewed_by, :bibl_review_postponed_until, :bibl_review_postpone_comment, :content_type, :xml, :datasource, :sourceid, :category_hsv_local => [], :series => [] ]
  end

  def create_basic_data
    params[:publication][:deleted_at] = nil
    params[:publication][:publication_type] = nil
    params[:publication][:publanguage] ||= 'en'
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

  def publication_identifier_permitted_params(params)
    params.require(:publication_identifier).permit(:publication_version_id, :identifier_code, :identifier_value)
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
    p2ps = People2publication.where(publication_version_id: publication_version_id)
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

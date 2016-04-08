# coding: utf-8
module PublicationsControllerHelper

  private

  def find_current_person
    if params[:xkonto].present?
      xkonto = params[:xkonto]
    else
      xkonto = @current_user.username
    end
    @current_person = Person.find_from_identifier(source: 'xkonto', identifier: xkonto)
    if @current_person
      @current_person_id = @current_person.id
    else
      @current_person_id = 0
    end
  end

  # Returns a list of publications, based on list type, current user and other parameters. 
  def publications_for_filter(list_type:, count_only: false)
    per_page = 100
    case list_type

    # Get drafts where current user has created or updated posts
    when "drafts"
      publications = Publication.where(deleted_at: nil).where(published_at: nil)
      user_publication_ids = PublicationVersion.
                             where('created_by = (?) or updated_by = (?)', 
                                   @current_user.username, @current_user.username).
                             select(:publication_id)
      publications = publications.where(id: user_publication_ids)

    # Get posts where current user is an actor
    when "is_actor"
      publications = Publication.where('current_version_id in (?)', People2publication.where('person_id = (?)', @current_person_id.to_i).map { |p| p.publication_version_id}).where.not(published_at: nil).where(deleted_at: nil)

    # Get posts where current user is an actor with affiliation to a department who hasn't reviewed post
    when "is_actor_for_review"
      # Find people2publications objects for person
      people2publications = People2publication.where(person_id: @current_person_id.to_i).where(reviewed_at: nil)

      # Find people2publications objects with affiliation to a department
      people2publications = people2publications.joins(:departments2people2publications)

      publication_version_ids = people2publications.select(:publication_version_id)

      # Find publications for filtered people2publication objects
      publications = Publication.where(current_version_id: publication_version_ids).where.not(published_at: nil).where(deleted_at: nil)
    # Get posts where current user has created or updated posts
    when "is_registrator"
      publications = Publication.where('current_version_id in (?)', PublicationVersion.where('created_by = (?) or updated_by = (?)', @current_user.username, @current_user.username).map { |p| p.id}).where.not(published_at: nil).where(deleted_at: nil)

    # Get posts that are published and not bibliographic reviewed.
    when "for_biblreview"
      per_page=20
      if @current_user.has_right?('bibreview')
        unreviewed_publication_ids = PublicationVersion
                                     .where(biblreviewed_at: nil)
                                     .select(:publication_id)
        if params[:only_delayed] && params[:only_delayed] == 'true'
           # Show only delayed publications
          publications = Publication
                         .where(deleted_at: nil)
                         .where.not(published_at: nil)
                         .where(id: unreviewed_publication_ids)
                         .where('biblreview_postponed_until > (?)', DateTime.now)
        else
          publications = Publication
                         .where(deleted_at: nil)
                         .where.not(published_at: nil)
                         .where(id: unreviewed_publication_ids)
                         .where('biblreview_postponed_until <= (?)', DateTime.now)
        end
      else
        #return error TBD
        publications = Publication.none
      end
    else
      publications = Publication.where(deleted_at: nil)
    end

    # ------------------------------------------------------------ #
    # FILTERS BLOCK START
    # ------------------------------------------------------------ #
    if params[:pubyear]  != 'alla år'
      if params[:pubyear] && params[:pubyear] != ''
        case params[:pubyear]
        when "1"
          pubyear_ids = PublicationVersion
                                 .where("pubyear >= ?", Time.now.year)
                                 .select(:publication_id)
          publications = publications.where(id: pubyear_ids)
        when "-1"
          pubyear_ids = PublicationVersion
                                 .where("pubyear <= ?", Time.now.year-5)
                                 .select(:publication_id)
          publications = publications.where(id: pubyear_ids)
        when "0"
        # publications=publication
        else
          pubyear_ids = PublicationVersion
                                 .where("pubyear = ?", params[:pubyear].to_i)
                                 .select(:publication_id)
          publications = publications.where(id: pubyear_ids)
        end
      end
    end

    if params[:pubtype]  != 'alla typer'
      if params[:pubtype] && params[:pubtype] != ''
        publication_type_ids = PublicationVersion
                               .where(publication_type: params[:pubtype])
                               .select(:publication_id)
        publications = publications.where(id: publication_type_ids)
      end
    end
    if params[:faculty] && params[:faculty] != ''
      departments_within_faculty = Department.where(faculty_id: params[:faculty]).select(:id)
      affiliations_for_departments = Departments2people2publication
                                     .where(department_id: departments_within_faculty)
                                     .select(:people2publication_id)
      publication_versions_from_faculty = People2publication
                                          .where(id: affiliations_for_departments)
                                          .select(:publication_version_id)
      publication_ids = PublicationVersion
                        .where(id: publication_versions_from_faculty)
                        .select(:publication_id)
      publications = publications.where(id: publication_ids)
    end
    # ------------------------------------------------------------ #
    # FILTERS BLOCK END
    # ------------------------------------------------------------ #
    return publications.count if count_only

    # ------------------------------------------------------------ #
    # PAGINATION BLOCK START
    # ------------------------------------------------------------ #
    pagination = {}
    metaquery = {}
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

    case list_type
    when "is_actor_for_review"
      publications_json = []
      publications.each do |publication|
        publication_json = publication.as_json
        
        publication_json['affiliation'] = person_for_publication(publication_version_id: publication.current_version_id, person_id: @current_person_id)
        
        publication_json['diff_since_review'] = find_diff_since_review(publication: publication, person_id: @current_person_id)
        publication_json[:authors] = people_for_publication(publication_version_id: publication.current_version_id)
        publications_json << publication_json
      end
      return publications_json
    end

    return publications
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

  # Returns a users affiliation to a specific publication
  def person_for_publication(publication_version_id:, person_id:)
    p2p = People2publication.where(publication_version_id: publication_version_id).where(person_id: person_id).first
    return nil if !p2p
    person = Person.where(id: person_id).first.as_json
    department_ids = Departments2people2publication.where(people2publication_id: p2p.id).select(:department_id)
    person['departments'] = Department.where(id: department_ids).as_json
    person
  end

end


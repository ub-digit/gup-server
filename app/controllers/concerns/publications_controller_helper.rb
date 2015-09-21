module PublicationsControllerHelper

  private

  def find_current_person
    if params[:xkonto].present?
      xkonto = params[:xkonto]
    else
      xkonto = @current_user.username
    end
    @current_person = Person.find_from_identifier(source: 'xkonto', identifier: xkonto)
  end

  # Returns a list of publications, based on list type, current user and other parameters. 
  def publications_for_filter(list_type:, count_only: false)
    per_page = 10
    case list_type

      # Get drafts where current user has created or updated posts
      when "drafts"
        publications = Publication.where('pubid in (?)', Publication.where('created_by = (?) or updated_by = (?)', @current_user.username, @current_user.username).map { |p| p.pubid}).where(published_at: nil).where(is_deleted: false)

      # Get posts where current user is an actor
      when "is_actor"
        publications = Publication.where('id in (?)', People2publication.where('person_id = (?)', @current_person.id.to_i).map { |p| p.publication_id}).where.not(published_at: nil).where(is_deleted: false)

       # Get posts where current user is an actor with affiliation to a department who hasn't reviewed post
      when "is_actor_for_review"
        # Find people2publications objects for person
        people2publications = People2publication.where(person_id: @current_person.id.to_i).where(reviewed_at: nil)

        # Find people2publications objects with affiliation to a department
        people2publications = people2publications.joins(:departments2people2publications)

        publication_ids = people2publications.map { |p| p.publication_id}

        # Find publications for filtered people2publication objects
        publications = Publication.where(id: publication_ids).where.not(published_at: nil).where(is_deleted: false)

      # Get posts where current user has created or updated posts
      when "is_registrator"
        publications = Publication.where('pubid in (?)', Publication.where('created_by = (?) or updated_by = (?)', @current_user.username, @current_user.username).map { |p| p.pubid}).where.not(published_at: nil).where(is_deleted: false)

      # Get posts that are published and not bibliographic reviewed.
      when "for_biblreview"
        if @current_user.has_right?('bibreview')
          publications = Publication.where(is_deleted: false).where.not(published_at: nil).where(biblreviewed_at: nil)
        else
          #return error TBD
          publications = Publication.none
        end

      else
        publications = Publication.where(is_deleted: false)
    end

    # ------------------------------------------------------------ #
    # FILTERS BLOCK START
    # ------------------------------------------------------------ #
    if params[:pubyear] && params[:pubyear] != ''
      case params[:pubyear]
      when "0"
          publications = publications.where("pubyear >= ?", Time.now.year)
      when "-1"
          publications = publications.where("pubyear <= ?", Time.now.year-2)
      else
          publications = publications.where("pubyear = ?", "#{params[:pubyear]}")
      end
    end

    if params[:pubtype] && params[:pubtype] != ''
        publications = publications.where("publication_type = ?", "#{params[:pubtype]}")
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
        publication_json['affiliation'] = person_for_publication(publication_db_id: publication.id, person_id: @current_person.id)
        publication_json['diff_since_review'] = find_diff_since_review(publication: publication, person_id: @current_person.id)
        publications_json << publication_json
      end
      return publications_json
    end

    return publications
  end



  # Returns collection of people including departments for a specific Publication
  def people_for_publication(publication_db_id:)
    p2ps = People2publication.where(publication_id: publication_db_id)
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
  def person_for_publication(publication_db_id:, person_id:)
    p2p = People2publication.where(publication_id: publication_db_id).where(person_id: person_id).first
    return nil if !p2p
    person = Person.where(id: person_id).first.as_json
    department_ids = Departments2people2publication.where(people2publication_id: p2p.id).select(:department_id)
    person['departments'] = Department.where(id: department_ids).as_json
    person
  end

end


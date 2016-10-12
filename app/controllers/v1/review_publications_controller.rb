class V1::ReviewPublicationsController < V1::V1Controller

  api :GET, '/review_publications', 'Returns a list of publications which have not yet been reviewed by given actor'
  def index
    person_ids = @current_user.person_ids
    if !person_ids
      @response['publications'] = []
      render_json
      return
    end

    # Find people2publications objects for person
    people2publications = People2publication.where(person_id: person_ids).where(reviewed_at: nil)

    # Find people2publications objects with affiliation to a department
    people2publications = people2publications.joins(:departments2people2publications)

    publication_version_ids = people2publications.select(:publication_version_id)

    # Find publications for filtered people2publication objects
    publications = Publication.where(current_version_id: publication_version_ids).where.not(published_at: nil).where(deleted_at: nil)


    publications_json = []
    publications.each do |publication|
      publication_json = publication.as_json

      publication_json['affiliation'] = person_for_publication(publication_version_id: publication.current_version_id, person_ids: person_ids)

      publication_json['diff_since_review'] = find_diff_since_review(publication: publication, person_ids: person_ids)
      publication_json[:authors] = people_for_publication(publication_version_id: publication.current_version_id)
      publications_json << publication_json
    end

    @response['publications'] = publications_json
    
    render_json
  end

  api :PUT, '/review_publications/:id', 'Sets a publications current versiona s reviewed for given actor'
  def update
    publication_version_id = params[:id]
    if !@current_user.person_ids
      error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "publications.person_not_found"}")
      render_json
      return
    end

    # Find applicable p2p object
    people2publication = People2publication.where(person_id: @current_user.person_ids).where(publication_version_id: publication_version_id).first

    if !people2publication
      error_msg(ErrorCodes::OBJECT_ERROR, "No affiliation found for publication")
      render_json
      return
    end

    if people2publication.publication_version.nil? || people2publication.publication_version.publication.published_at.nil?
      error_msg(ErrorCodes::OBJECT_ERROR, "Publication is not in a reviewable state")
      render_json
      return
    end

    people2publication.update_attributes(reviewed_at: DateTime.now, reviewed_publication_version_id: publication_version_id)

    if people2publication.save!
      @response[:publication] = {}
      @response[:publication][:msg] = "Review succesful!"
      render_json
    else
      error_msg(ErrorCodes::VALIDATION_ERROR, "Could not review object")
      render_json
    end
  end

  private

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

  # Returns a users affiliation to a specific publication
  def person_for_publication(publication_version_id:, person_ids:)
    p2p = People2publication.where(publication_version_id: publication_version_id).where(person_id: person_ids).first
    return nil if !p2p
    person = Person.where(id: person_ids).first.as_json
    department_ids = Departments2people2publication.where(people2publication_id: p2p.id).select(:department_id)
    person['departments'] = Department.where(id: department_ids).as_json
    person
  end

  def find_diff_since_review(publication:, person_ids:)
    p2p = People2publication.where(person_id: person_ids).where(publication_version_id: publication.current_version_id).first
    if !p2p || p2p.reviewed_publication_version.nil?
      return {}
    else
      # Add diffs from publication object
      diff = publication.current_version.review_diff(p2p.reviewed_publication_version)
      
      # Add diffs from affiliations
      oldp2p = People2publication.where(person_id: person_ids).where(publication_version_id: p2p.reviewed_publication_version_id).first

      if oldp2p
        old_affiliations = oldp2p.departments2people2publications.map {|x| x.department_id}
        new_affiliations = p2p.departments2people2publications.map {|x| x.department_id}

        unless (old_affiliations & new_affiliations == old_affiliations) && (new_affiliations & old_affiliations == new_affiliations)
          diff[:affiliation] = {from: Department.where(id: old_affiliations), to: Department.where(id: new_affiliations)}
        end
      end
      
      if diff.blank?
        return {}
      end
      
      diff[:reviewed_at] = oldp2p.reviewed_at
      return diff
    end
  end

end

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

  # Returns posts where given person_id is an actor with affiliation to a department who hasn't reviewed post
  def publications_for_review_by_actor(person_id: person_id, count_only: false)

    # Find people2publications objects for person
    people2publications = People2publication.where(person_id: person_id.to_i).where(reviewed_at: nil)

    # Find people2publications objects with affiliation to a department
    people2publications = people2publications.joins(:departments2people2publications)

    publication_ids = people2publications.map { |p| p.publication_id}

    # Find publications for filtered people2publication objects
    publications = Publication.where(id: publication_ids).where.not(published_at: nil).where(is_deleted: false)

    return publications.count if count_only

    publications_json = []
    publications.each do |publication|
      publication_json = publication.as_json
      publication_json['affiliation'] = person_for_publication(publication_db_id: publication.id, person_id: person_id)
      publication_json['diff_since_review'] = find_diff_since_review(publication: publication, person_id: person_id)
      publications_json << publication_json
    end

    return publications_json

  end
end


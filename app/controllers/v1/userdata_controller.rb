class V1::UserdataController < V1::V1Controller
  def show
    review_count = 0
    if @current_user.person_ids
      review_count = publication_count_for_review
    end
    @response[:userdata] = {
      counts: {
        review: review_count
      }
    }

    render_json
  end
  
  private
  def publication_count_for_review
    # Find people2publications objects for person
    people2publications = People2publication.where(person_id: @current_user.person_ids).where(reviewed_at: nil)
    
    # Find people2publications objects with affiliation to a department
    people2publications = people2publications.joins(:departments2people2publications)
    publication_version_ids = people2publications.select(:publication_version_id)
    
    # Find publications for filtered people2publication objects
    publications = Publication.where(current_version_id: publication_version_ids).where.not(published_at: nil).where(deleted_at: nil)
    return publications.count
  end
end

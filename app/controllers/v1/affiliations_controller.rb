class V1::AffiliationsController < V1::V1Controller

  api!
  def affiliations_for_actor
    person_id = params[:person_id]
    if person_id
      publication_ids = Publication.where.not(published: nil).where(is_deleted: false).map {|publ| publ.id}
      puts publication_ids
      people2publication_ids = People2publication.where('publication_id in (?)', publication_ids).where('person_id = (?)', person_id.to_i).map { |p| p.id}
      affiliations = Departments2people2publication.where('people2publication_id in (?)', people2publication_ids).order(updated_at: :desc)
      @response[:affiliations] = affiliations
      render_json
    else
      error_msg(404, "#{I18n.t "affiliations.errors.no_person_id"}")
      render_json
    end
  end

end

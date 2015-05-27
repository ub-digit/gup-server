class V1::AffiliationsController < ApplicationController

  api!
  def affiliations_for_actor
    person_id = params[:person_id]
    if person_id
      publication_ids = Publication.where(is_draft: false).where(is_deleted: false).map {|publ| publ.id}
      puts publication_ids
      people2publicaion_ids = People2publication.where('publication_id in (?)', publication_ids).where('person_id = (?)', person_id.to_i).map { |p| p.id}
      affiliations = Departments2people2publication.where('people2publication_id in (?)', people2publicaion_ids).order(updated_at: :desc)
      @response[:affiliations] = affiliations
      render_json(200)
    else
      generate_error(404, "No person_id was given")
      render_json
    end
  end

end

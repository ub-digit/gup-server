class V1::AffiliationsController < ApplicationController

  api!
  def affiliations_for_actor
    person_id = params[:person_id]
    if person_id
      publication_ids = Publication.where.not(published: nil).where(is_deleted: false).map {|publ| publ.id}
      puts publication_ids
      people2publicaion_ids = People2publication.where('publication_id in (?)', publication_ids).where('person_id = (?)', person_id.to_i).map { |p| p.id}
      affiliations = Departments2people2publication.where('people2publication_id in (?)', people2publicaion_ids).order(updated_at: :desc)
      @response[:affiliations] = affiliations
      render_json
    else
      generate_error(404, "#{I18n.t "affiliations.errors.no_person_id"}")
      render_json
    end
  end

end

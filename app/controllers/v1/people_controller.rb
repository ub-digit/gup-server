class V1::PeopleController < ApplicationController

  api!
  def index
    search_term = params[:search_term] || ''
    fetch_xkonto = params[:xkonto] || ''

    @people = Person.all

    if fetch_xkonto.present?

      xkonto = fetch_xkonto.downcase

      source_hit = Identifier.where(
        "lower(value) LIKE ?",
        "#{xkonto}"
        ).where(source_id: Source.find_by_name("xkonto").id)
      .select(:person_id)

      @people = @people.where(id: source_hit)

    elsif search_term.present?
      st = search_term.downcase

      alternative_name_hit = AlternativeName.where(
        "(lower(first_name) LIKE ?)
        OR (lower(last_name) LIKE ?)",
        "%#{st}%", "%#{st}%"
        ).select(:person_id)

      source_hit = Identifier.where(
        "lower(value) LIKE ?",
        "%#{st}%"
        ).select(:person_id)

      @people = @people.where(
        "(((lower(first_name) LIKE ?)
          OR (lower(last_name) LIKE ?))
      AND (affiliated = true))
      OR (id IN (?) AND (affiliated = true))
      OR (id IN (?))",
      "%#{st}%",
      "%#{st}%",
      alternative_name_hit,
      source_hit
      )

      logger.info "SQL for search gup-people: #{@people.to_sql}"
    end
    return_array = []
    @people.each do |person|
      presentation_string = person.presentation_string(affiliations_for_actor(person_id: person.id))
      person = person.as_json
      person[:presentation_string] = presentation_string
      return_array << person
    end
    @response[:people] = return_array
    render_json
  end

  api!
  def show
    personid = params[:id]
    person = Person.find_by_id(personid)
    if person.present?
      @response[:person] = person
    else
      generate_error(404, "#{I18n.t "people.errors.not_found"}: #{params[:id]}")
    end
    render_json
  end

  api!
  def create
    person_params = permitted_params
    parameters = ActionController::Parameters.new(person_params)
    obj = Person.new(parameters.permit(:first_name, :last_name, :year_of_birth, :affiliated))

    if obj.save
      if params[:person][:xaccount].present?
        Identifier.create(person_id: obj.id, source_id: Source.find_by_name('xkonto').id, value: params[:person][:xaccount])
      end
      if params[:person][:orcid].present?
        Identifier.create(person_id: obj.id, source_id: Source.find_by_name('orcid').id, value: params[:person][:orcid])
      end
      url = url_for(controller: 'people', action: 'create', only_path: true)
      headers['location'] = "#{url}/#{obj.id}"
      @response[:person] = obj.as_json
    else
      generate_error(422, "#{I18n.t "people.errors.create_error"}", obj.errors.messages)
    end
    render_json(201)
  end

  api!
  def update
    person_id = params[:id]
    person = Person.find_by_id(person_id)
    if person.present?
      if person.update_attributes(permitted_params)
        @response[:person] = person
        render_json
      else
        generate_error(422, "#{I18n.t "people.errors.update_error"}: #{params[:id]}", person.errors)
        render_json
      end
    else
      generate_error(404, "#{I18n.t "people.errors.not_found"}: #{params[:id]}")
      render_json
    end
  end

  private
  def permitted_params
    params.require(:person).permit(:first_name, :last_name, :year_of_birth, :affiliated, :identifiers, :alternative_names, :xaccount, :orcid)
  end

  def affiliations_for_actor(person_id:)
    publication_ids = Publication.where(is_draft: false).where(is_deleted: false).map {|publ| publ.id}
    people2publication_ids = People2publication.where('publication_id in (?)', publication_ids).where('person_id = (?)', person_id.to_i).map { |p| p.id}
    d2p2ps = Departments2people2publication.where('people2publication_id in (?)', people2publication_ids).order(updated_at: :desc)
    departments = Department.where(id: d2p2ps)
    departments.map{|p| p.name}.uniq[0..1]
  end
end

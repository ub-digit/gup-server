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

    @response[:people] = @people.as_json
    render_json
  end

  api!
  def show
    personid = params[:id]
    person = Person.find_by_id(personid)
    if person.present?
      @response[:person] = person
      render_json
    else
      generate_error(404, "Could not find person #{params[:id]}")
      render_json
    end
  end

  api!
  def create
    person = Person.new(permitted_params)
    if person.save
      @response[:person] = person
      render_json(201)
    else
      generate_error(422, "Could not create person", person.errors)
      render_json
    end
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
        generate_error(422, "Could not update person #{params[:id]}", person.errors)
        render_json
      end
    else
      generate_error(404, "Could not find person #{params[:id]}")
      render_json
    end
  end

  private
  def permitted_params
    params.require(:person).permit(:first_name, :last_name, :year_of_birth, :affiliated, :identifiers, :alternative_names, :xaccount, :orcid)
  end
end

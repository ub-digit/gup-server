class PeopleController < ApplicationController
  def index
  	p = {}
    if params[:xkonto]
      p[:xkonto] = params[:xkonto]
  	elsif params[:search_term]
      p[:search_term] = params[:search_term]
    end
    people = Person.find(:all, params: p)
    render json: {people: people}, status: 200
  end

  def show
    personid = params[:id]
    person = Person.find(personid)
    render json: {person: person}, status: 200
  rescue ActiveResource::ResourceNotFound
    render json: {error: "Person not found"}, status: 404
  end

  def create
  	person = Person.new(permitted_params)
    if person.save
      render json: {person: person}, status: 201
    else
      render json: {error: person.errors}, status: 422
    end
  end

  def update
  	person_id = params[:id]
    person = Person.find(person_id)
    if person.update_attributes(permitted_params)
      render json: {person: person}, status: 200
    else
      render json: {error: person.errors}, status: 422
    end
  rescue ActiveResource::ResourceNotFound
    render json: {error: "Person not found"}, status: 404
  end

private
  def permitted_params
    params.require(:person).permit(:first_name, :last_name, :year_of_birth, :affiliated, :identifiers, :alternative_names, :xaccount, :orcid)
  end

end

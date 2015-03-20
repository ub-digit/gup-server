class PublicationsController < ApplicationController

  def index
    if params[:drafts] == 'true'
      publications = Publication.find(:all, from: :drafts, params: {username: @current_user.username})
    elsif params[:is_actor] == 'true'
      person = Person.find(:first, params: {xkonto: @current_user.username})
      if person
        person_id = person.id
        publications = Publication.find(:all, params: {is_actor: 'true', person_id: person_id})
      else
        publications = []
      end
    elsif params[:is_registrator] == 'true'
      publications = Publication.find(:all, params: {is_registrator: 'true', username: @current_user.username})
    else
      publications = Publication.find(:all)
    end
    render json: {publications: publications}, status: 200
  end

  def show
    pubid = params[:pubid]
    publication = Publication.find(pubid)
    render json: {publication: publication}, status: 200
  rescue ActiveResource::ResourceNotFound
    render json: {error: "Publication not found"}, status: 404
  end

  def create
    if params[:datasource]
      publication = Publication.new({datasource: params[:datasource], sourceid: params[:sourceid], username: @current_user.username})
    elsif params[:file]
      publication = Publication.new({file: params[:file], username: @current_user.username})
    else
      publication = Publication.new({datasource: 'none', username: @current_user.username})   
    end

    if publication.save
      render json: {publication: publication}, status: 201
    else
      render json: {error: publication.errors}, status: 422
    end
  end

  def update
  	pubid = params[:pubid]
    publication = Publication.find(pubid)
    params[:publication][:updated_by] = @current_user.username
    if publication.update_attributes(params[:publication])
      render json: {publication: publication}, status: 200
    else
      render json: {error: publication.errors}, status: 422
    end
  rescue ActiveResource::ResourceNotFound
    render json: {error: "Publication not found"}, status: 404
  end

  def destroy
    pubid = params[:pubid]
    publication = Publication.find(pubid)
    publication.destroy
    render json: {}, status: 200

#    if publication.destroy
#      render json: {}, status: 200
#    else
#      render json: {error: "Error deleting publication"}, status: 422
#    end
  rescue ActiveResource::ResourceNotFound
    render json: {error: "Publication not found"}, status: 404
  end

end

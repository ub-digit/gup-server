class PublicationsController < ApplicationController

  def index
    if params[:drafts] == 'true'
      publications = Publication.get(:drafts)
    else
      publications = Publication.all
    end
    render json: {publications: publications}, status: 200
  end

  def show
    pubid = params[:id]
    publication = Publication.find(pubid)
    render json: {publication: publication}, status: 200
  rescue ActiveResource::ResourceNotFound 
    render json: {error: "Publication not found"}, status: 404
  end

  def create
  	datasource = params[:datasource]
  	publication = Publication.new(datasource: datasource)
    if publication.save
      render json: {publication: publication}, status: 201
    else
      render json: {error: "Error creating publication"}, status: 422
    end    	
  end

  def update
  	pubid = params[:id]
    publication = Publication.find(pubid)
    if publication.update_attributes(params[:publication])
      render json: {publication: publication}, status: 200
    else
      render json: {error: "Error updating publication"}, status: 422
    end
  rescue ActiveResource::ResourceNotFound 
    render json: {error: "Publication not found"}, status: 404
  end

  def destroy
    pubid = params[:id]
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



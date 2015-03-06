class PublicationTypesController < ApplicationController

  def index
    publication_types = PublicationType.all
    render json: {publication_types: publication_types}, status: 200    
  end

  def show
    pubtype_id = params[:id]
    publication_type = PublicationType.find(pubtype_id)
    render json: {publication_type: publication_type}, status: 200
  rescue ActiveResource::ResourceNotFound 
    render json: {error: "Publication type not found"}, status: 404
  end

end

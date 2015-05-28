class V1::PublicationTypesController < ApplicationController
  api!
  def index
    publication_types = PublicationType.all
    render json: {publication_types: publication_types}, status: 200    
  end

  api!
  def show
    publication_type = PublicationType.find_by_code(params[:id])
    if publication_type.present?
      render json: {publication_type: publication_type}, status: 200
    else
      render json: {error: "Publication type not found: #{params[:id]}"}, status: 404
    end
  end
end

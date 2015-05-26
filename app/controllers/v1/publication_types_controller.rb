class V1::PublicationTypesController < ApplicationController
  api!
  def index
    publication_types = PublicationType.all
    render json: {publication_types: publication_types}, status: 200    
  end

  api!
  def show
    publication_type = PublicationType.find_by_id(params[:id])
    if publication_type.present?
      render json: {publication_type: publication_type}, status: 200
    else
      render json: {error: "Publication type not found: #{params[:id]}"}, status: 404
    end
  end

  api!
  def create
    pub = PublicationType.new(permitted_params)
    if pub.save!
      render json: pub.to_json(root: true)
    else
      render json: {errors: pub.errors}, status: 400
    end
  end

#  api!
#  def update
#    render json: {type_id: params[:id]}
#  end
#
#  api!
#  def destroy
#    render json: {type_id: params[:id]}
#  end

private
  def permitted_params
    params.require(:publication_type).permit(:code)
  end
end

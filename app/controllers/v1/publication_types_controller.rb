class V1::PublicationTypesController < ApplicationController
  api!
  def index
    render json: {test: "hej"}
  end

  api!
  def show
    render json: {type_id: params[:id]}
  end

  api!
  def update
    render json: {type_id: params[:id]}
  end

  api!
  def destroy
    render json: {type_id: params[:id]}
  end
end

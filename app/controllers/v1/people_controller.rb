class V1::PeopleController < ApplicationController
  api!
  def index
    render json: {test: "hej"}
  end

  api!
  def show
    render json: {person_id: params[:id]}
  end

  api!
  def update
    render json: {person_id: params[:id]}
  end

  api!
  def destroy
    render json: {person_id: params[:id]}
  end
end

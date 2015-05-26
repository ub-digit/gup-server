class V1::PublicationsController < ApplicationController

  api!
  def index
    render json: {test: "hej"}
  end

  api!
  def show
    render json: {pubid: params[:pubid]}
  end

  api!
  def update
    render json: {pubid: params[:pubid]}
  end

  api!
  def destroy
    render json: {pubid: params[:pubid]}
  end

end

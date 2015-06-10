class V1::CategoriesController < ApplicationController

  api!
  def index
    @response[:categories] = Category.find_by_query(params[:query]).as_json({light: true})
    render_json
  end

  api!
  def show
    category = Category.find(params[:id])
    if !category
      generate_error(404, "Category with id #{params[:id]} not found")
    else
      @response[:category] = category
    end
    render_json
  end
end

class V1::CategoriesController < ApplicationController

  api!
  def index
    if (params[:query].blank?)
      @response[:categories] = APP_CONFIG['categories_tree'] 
    else
      @response[:categories] = Category.find_by_query(params[:query])
    end
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

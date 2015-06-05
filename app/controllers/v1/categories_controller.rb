class V1::CategoriesController < ApplicationController

  api!
  def index
    @response[:categories] = APP_CONFIG['categories_tree'] 
    render_json
  end
end

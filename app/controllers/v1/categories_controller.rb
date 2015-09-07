class V1::CategoriesController < V1::V1Controller

  api :GET, '/categories', 'Returns all available categories'
  def index
    @response[:categories] = Category.find_by_query(params[:query]).as_json({light: true})
    render_json
  end

  api :GET, '/categories/:id', 'Returns a single category object based on svepid'
  def show
    category = Category.find(params[:id])
    if !category
      error_msg(404, "Category with id #{params[:id]} not found")
    else
      @response[:category] = category
    end
    render_json
  end
end

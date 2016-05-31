class V1::CategoriesController < V1::V1Controller

  api :GET, '/categories', 'Returns all available categories'
  def index
    query = params[:query]
    categories = Category.where(category_type: 'HSV_LOCAL_12')

    if query.present?
      categories = categories.find_by_query(query: query).as_json({light: true})
      @response[:categories] = categories.as_json({light: true})
    else
      categories = categories.where(parent_id: nil)
      @response[:categories] = categories
    end

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

class V1::SourcesController < V1::V1Controller
  
  api :GET, '/sources', 'Returns a list of all available sources'
  def index
    sources = Source.all

    @response[:sources] = sources.as_json
    render_json
  end

  api :POST, '/sources', 'Creates a new source'
  def create
    source_params = params[:source]
    parameters = ActionController::Parameters.new(source_params)
    obj = Source.new(parameters.permit(:name))

    if obj.save
      url = url_for(controller: 'sources', action: 'create', only_path: true)
      headers['location'] = "#{url}/#{obj.id}"
      @response[:source] = obj.as_json
    else
      error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "sources.errors.create_error"}", obj.errors.messages)
    end
    render_json(201)
  end

  api :GET, '/sources/:id', 'Returns a single source object.'
  def show
    id = params[:id]
    obj = Source.find_by id: id

    if obj
      @response[:source] = obj.as_json
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "sources.errors.not_found"}")
    end
    render_json
  end

  api :PUT, '/sources/:id', 'Updates a source object.'
  def update
    source_params = params[:source]
    parameters = ActionController::Parameters.new(source_params)
    id = params[:id]
    obj = Source.find_by id: id

    if obj
      if obj.update(parameters.permit(:name))
        @response[:source] = obj.as_json
      else
        error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "sources.errors.update_error"}", obj.errors.messages)
      end
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "sources.errors.not_found"}")
    end
    render_json
  end
end

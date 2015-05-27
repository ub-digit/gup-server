class V1::SourcesController < ApplicationController
  
  api!
  def index
    sources = Source.all

    @response[:sources] = sources.as_json
    render_json
  end

  api!
  def create
    source_params = params[:source]
    parameters = ActionController::Parameters.new(source_params)
    obj = Source.new(parameters.permit(:name))

    if obj.save
      url = url_for(controller: 'sources', action: 'create', only_path: true)
      headers['location'] = "#{url}/#{obj.id}"
      @response[:source] = obj.as_json
    else
      generate_error(422, "Could not create the source", obj.errors.messages)
    end
    render_json(201)
  end

  api!
  def show
    id = params[:id]
    obj = Source.find_by id: id

    if obj
      @response[:source] = obj.as_json
    else
      generate_error(404)
    end
    render_json
  end

  api!
  def update
    source_params = params[:source]
    parameters = ActionController::Parameters.new(source_params)
    id = params[:id]
    obj = Source.find_by id: id

    if obj
      if obj.update(parameters.permit(:name))
        @response[:source] = obj.as_json
      else
        generate_error(422, "Could not update the source", obj.errors.messages)
      end
    else
      generate_error(404, "Could not find the source to update")
    end
    render_json
  end
end

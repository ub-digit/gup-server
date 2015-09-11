class V1::ProjectsController < V1::V1Controller
  
  api :GET, '/projects', 'Returns a list of all available projects'
  def index
    render json: Project.as_json
  end

end

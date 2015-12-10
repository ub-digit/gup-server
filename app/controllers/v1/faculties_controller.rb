class V1::FacultiesController < V1::V1Controller
  
  api :GET, '/faculties', 'Returns a list of all configurated faculties'
  def index
    faculties = Faculty.all
    @response[:faculties] = faculties
    render_json
  end
end

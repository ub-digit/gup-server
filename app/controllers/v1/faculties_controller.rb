class V1::FacultiesController < V1::V1Controller
  
  api :GET, '/faculties', 'Returns a list of all configurated faculties'
  def index
    faculties = Faculty.all
    if I18n.locale == :en
      @response[:faculties] = faculties.order(name_en: :asc)
    else
      @response[:faculties] = faculties.order(name_sv: :asc)
    end    
    render_json
  end
end

class V1::LanguagesController < V1::V1Controller

  api :GET, '/languages', 'Returns a list of all languages available to assign to a publication.'
  def index
    @response[:languages] = Language.all
    render_json
  end
end

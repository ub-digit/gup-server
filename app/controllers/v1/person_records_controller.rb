class V1::PersonRecordsController < V1::V1Controller

  api :GET, '/person_records', 'Returns a list of person records based on given parameters.'
  param :search_term, String, :desc => 'String query which searches based on any name and identifier that might be present.'
  def index
    search_term = params[:search_term]
    # Perform SOLR search
    result = PeopleSearchEngine.query(search_term, 1, 40)
    docs = result['response']['docs']
    
    @response[:person_records] = docs
    render_json
  end
end
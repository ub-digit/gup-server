class V1::PersonRecordsController < V1::V1Controller

  api :GET, '/people', 'Returns a list of person records based on given parameters.'
  param :search_term, String, :desc => 'String query which searches based on any name and identifier that might be present.'
  param :xkonto, String, :desc => 'Searches amongst available xkonto identifiers.'
  def index
    search_term = params[:search_term]
    # Perform SOLR search
    result = PeopleSearchEngine.query(search_term)
    docs = result['response']['docs']
    
    puts docs.inspect
    @response[:person_records] = docs
    render_json
  end
end
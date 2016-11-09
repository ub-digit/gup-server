class V1::PublicationRecordsController < V1::V1Controller

  api :GET, '/publication_records', 'Returns a list of publication records based on given parameters.'
  param :search_term, String, :desc => 'String query which searches based on any name and identifier that might be present.'
  def index
    search_term = params[:search_term]
    # Perform SOLR search
    # TODO Pagination...
    result = PublicationSearchEngine.query(search_term, 1, 50)
    docs = result['response']['docs']
    
    @response[:publication_records] = docs
    render_json
  end
end
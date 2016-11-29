class V1::PersonRecordsController < V1::V1Controller

  api :GET, '/person_records', 'Returns a list of person records based on given parameters.'
  param :search_term, String, :desc => 'String query which searches based on any name and identifier that might be present.'
  def index
    search_term = params[:search_term]
    ignore_affiliation = params[:ignore_affiliation]
    affiliation_term = (ignore_affiliation ? "has_affiliations:*" : "has_affiliations:true")
pp [search_term, affiliation_term]
    # Perform SOLR search
    result = PeopleSearchEngine.query(search_term, 1, 40, affiliation_term)
    docs = result['response']['docs']
    
    @response[:person_records] = docs
    render_json
  end
end
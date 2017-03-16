class V1::PersonRecordsController < ApplicationController

  api :GET, '/person_records', 'Returns a list of person records based on given parameters.'
  param :search_term, String, :desc => 'String query which searches based on any name and identifier that might be present.'
  def index
    search_term = params[:search_term]
    ignore_affiliation = params[:ignore_affiliation]

    # consider person as affiliated if it has affiliations or xaccount or orcid
    affiliation_term = (ignore_affiliation ? "has_affiliations:*" : "(has_affiliations:true OR xaccount:* OR orcid:*)")

    # Perform SOLR search
    result = PeopleSearchEngine.query(search_term, 1, 100, affiliation_term)
    docs = result['response']['docs']

    @response[:person_records] = docs
    render_json
  end
end

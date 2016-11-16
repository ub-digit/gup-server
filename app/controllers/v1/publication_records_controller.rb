class V1::PublicationRecordsController < V1::V1Controller

  api :GET, '/publication_records', 'Returns a list of publication records based on given parameters.'
  param :search_term, String, :desc => 'String query which searches based on any name and identifier that might be present.'
  def index
    search_term = params[:search_term]
    page = (params[:page] || 1).to_i
    per_page = 20

    # Perform SOLR search
    result = PublicationSearchEngine.query(search_term, page, per_page)
    docs = result['response']['docs']
    total = result['response']['numFound']
    publication_ids = docs.map{|doc| doc["id"]}
    
    # Keep the order from solr
    publication_objects = Publication.where('id in (?)', publication_ids).index_by(&:id)
    publications = publication_ids.map{|id| publication_objects[id]}

    meta = create_meta_block(total: total, page: page)

    @response[:publications] = publications.as_json(include_authors: true)
    @response[:meta] = meta

    render_json(200)
  end
  
private 
  def create_meta_block (total:, page:, per_page: 20)
    meta = {} 
    pagination = {}
    metaquery = {total: total}

    total_pages = (total.to_f / per_page.to_f).ceil
    pagination[:pages] = total_pages
    pagination[:page] = page
    pagination[:next] =  page <= total_pages ? page + 1 : nil
    pagination[:previous] = page > 1 ? page - 1 : nil
    pagination[:per_page] = per_page
    meta[:query] = metaquery
    meta[:pagination] = pagination
    return meta
  end

end


class V1::JournalsController < V1::V1Controller

  def search
    search_term = params[:search_term]
    response = solr.get 'select', :params => {:q => search_term, :fl => ['title', 'journalid', 'journal_identifier_mapping'], :wt => 'ruby'}

    @response[:journals] = response["response"]["docs"].map do |journal|
      id = journal["journalid"]
      title = journal["title"]
      issn = get_element journal["journal_identifier_mapping"], "issn"
      eissn = get_element journal["journal_identifier_mapping"], "eissn"
      {id: id, title: title, issn: issn, eissn: eissn}
    end
    render_json
  end

  def get_element list, type
    list.each do |field|
      return field.split(/:/).last if field.start_with?("#{type}:")
    end
    return nil
  end

  def solr
    @@rsolr ||= RSolr.connect(url: APP_CONFIG['journal_index_url'])
  end
end

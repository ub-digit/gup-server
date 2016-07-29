class SearchEngine
  
  def add(data: data)
    begin
      solr.add(data)
    rescue RSolr::Error::Http
      # TODO
    end
  end

  def delete_from_index(id: id)
    solr.delete_by_id(id)
  end

  def commit
    solr.update :data => '<commit/>'
    solr.update :data => '<optimize/>'
  end

  def clear(confirm: false)
    return if !confirm
    solr.delete_by_query("*:*")
    solr.commit
  end

end

class Libris < LibrisAdapter
  def as_json options = {}
    {
      title: title,
      alt_title: alt_title,
      abstract: abstract,
      pubyear: pubyear,
      keywords: keywords,
      author: author,
      extent: extent,
      publanguage: language,
      sourcetitle: sourcetitle,
      isbn: isbn,
      links: links,
      extid: extid
    }
  end
end


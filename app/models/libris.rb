class Libris < LibrisAdapter
  def as_json options = {}
    {
      title: title,
      alt_title: alt_title,
      abstract: abstract,
      pubyear: pubyear,
      keywords: keywords,
      #author: author,
      extent: extent,
      publanguage: Language.language_code_map(language),
      sourcetitle: sourcetitle,
      isbn: isbn,
      links: links,
      extid: extid,
      xml: xml,
      datasource: datasource,
      sourceid: sourceid,
      publication_identifiers: publication_identifiers
    }
  end
end


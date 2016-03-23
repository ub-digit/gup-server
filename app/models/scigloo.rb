class Scigloo < SciglooAdapter
  def as_json options = {}
    {
      title: title,
      alt_title: alt_title,
      abstract: abstract,
      pubyear: pubyear,
      keywords: keywords,
      #author: author,
      publanguage: Language.language_code_map(language),
      sourcetitle: sourcetitle,
      sourceissue: sourceissue,
      sourcevolume: sourcevolume, 
      sourcepages: sourcepages,
      issn: issn,
      links: links,
      extid: sgid,
      xml: xml,
      category_hsv_local: category_hsv_local,
      datasource: datasource,
      sourceid: sourceid,
      publication_identifiers: publication_identifiers
    }
  end
end


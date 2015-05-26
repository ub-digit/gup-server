class Scopus < ScopusAdapter
  def as_json options = {}
    {
      title: title,
      alt_title: alt_title,
      abstract: abstract,
      pubyear: pubyear,
      keywords: keywords,
      author: author,
      publanguage: language,
      sourcetitle: sourcetitle,
      sourceissue: sourceissue,
      sourcevolume: sourcevolume, 
      sourcepages: sourcepages,
      issn: issn,
      eissn: eissn,
      links: doi_url,
      extid: extid
    }
  end
end


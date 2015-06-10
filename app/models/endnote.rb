class Endnote < EndnoteAdapter
  def as_json options = {}
    {
      title: title,
      alt_title: alt_title,
      abstract: abstract,
      pubyear: pubyear,
      keywords: keywords,
      #author: author,
      publanguage: language,
      sourcetitle: sourcetitle,
      sourceissue: sourceissue,
      sourcevolume: sourcevolume, 
      sourcepages: sourcepages,
      issn: issn,
      publisher: publisher, 
      place: place, 
      extent: extent, 
      isbn: isbn, 
      patent_applicant: patent_applicant, 
      patent_date: patent_date,
      patent_number: patent_number,
      links: doi_url,
      extid: extid,
      xml: xml
    }
  end
end


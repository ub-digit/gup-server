class Gupea < GupeaAdapter
  def as_json options = {}
    {
      title: title,
      alt_title: alt_title,
      abstract: abstract,
      pubyear: pubyear,
      keywords: keywords,
      author: author,
      publanguage: language,
      isbn: isbn,
      links: links,
      sourcetitle: sourcetitle,
      artwork_type: artwork_type,
      disslocation: disslocation, 
      dissdate: dissdate
    }
  end
end


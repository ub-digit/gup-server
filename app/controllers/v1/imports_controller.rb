class V1::ImportsController < V1::V1Controller

  api :POST, '/imports', 'Returns a non persisted publication object based on data imported from a given data source.'
  #param :datasource, ['pubmed', 'gupea', 'scopus', 'libris', 'scigloo'], :desc => 'Declares which data source should be used to import data from.', :required => true
  #param :sourceid, String, :desc => 'The identifier used to import publication data from given data source.', :required => true
  def create
    datasource = params[:publication][:datasource]
    sourceid = params[:publication][:sourceid]
    publication = {}

    case datasource
    when "none"
      #do nothing
    when "pubmed"
      pubmed = Pubmed.find_by_id(sourceid)
      if pubmed && pubmed.errors.messages.empty?
        pubmed.datasource = datasource
        pubmed.sourceid = sourceid
        publication.merge!(pubmed.as_json)
      else
        error_msg(ErrorCodes::VALIDATION_ERROR, "Identifikatorn #{sourceid} hittades inte i Pubmed.")
        render_json
        return
      end
    when "gupea"
      gupea = Gupea.find_by_id(sourceid)
      if gupea && gupea.errors.messages.empty?
        gupea.datasource = datasource
        gupea.sourceid = sourceid
        publication.merge!(gupea.as_json)
      else
        error_msg(ErrorCodes::VALIDATION_ERROR, "Identifikatorn #{sourceid} hittades inte i Gupea")
        render_json
        return
      end
    when "libris"
      libris = Libris.find_by_id(sourceid)
      if libris && libris.errors.messages.empty?
        libris.datasource = datasource
        libris.sourceid = sourceid
        publication.merge!(libris.as_json)
      else
        error_msg(ErrorCodes::VALIDATION_ERROR, "Identifikatorn #{sourceid} hittades inte i Libris")
        render_json
        return
      end
    when "scopus"
      scopus = Scopus.find_by_id(sourceid)
      if scopus && scopus.errors.messages.empty?
        scopus.datasource = datasource
        scopus.sourceid = sourceid
        publication.merge!(scopus.as_json)
      else
        error_msg(ErrorCodes::VALIDATION_ERROR, "Identifikatorn #{sourceid} hittades inte i Scopus")
        render_json
        return
      end
    when "scigloo"
      scigloo = Scigloo.find_by_id(sourceid)
      if scigloo && scigloo.errors.messages.empty?
        scigloo.datasource = datasource
        scigloo.sourceid = sourceid
        publication.merge!(scigloo.as_json)
      else
        error_msg(ErrorCodes::VALIDATION_ERROR, "Identifikatorn #{sourceid} hittades inte i Scigloo")
        render_json
        return
      end
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "Given datasource is not configured: #{datasource}")
    end

    # Check publication identifiers for possible duplications
    publication_identifiers = publication[:publication_identifiers] || []
    publication_identifier_duplicates = []
    
    publication_identifiers.each do |publication_identifier|
      duplicates = PublicationIdentifier.where(identifier_code: publication_identifier['identifier_code'], identifier_value: publication_identifier['identifier_value']).select(:publication_version_id)
      duplicate_publications = Publication.where(deleted_at: nil).where.not(published_at: nil).where(current_version_id: duplicates)
      duplicate_publications.each do |duplicate_publication|
        duplication_object = {
          identifier_code: publication_identifier['identifier_code'],
          identifier_value: publication_identifier['identifier_value'],
          publication_version_id: duplicate_publication.current_version.id,
          publication_title: duplicate_publication.current_version.title
        }
        publication_identifier_duplicates << duplication_object
      end
    end

    publication[:publication_identifier_duplicates] = publication_identifier_duplicates

    @response[:publication] = publication
    render_json

  end

end

class V1::ImportsController < V1::V1Controller

  api :POST, '/imports', 'Returns a non persisted publication object based on data imported from a given data source.'
  #param :datasource, ['pubmed', 'gupea', 'scopus', 'libris', 'scigloo'], :desc => 'Declares which data source should be used to import data from.', :required => true
  #param :sourceid, String, :desc => 'The identifier used to import publication data from given data source.', :required => true
  def create
    datasource = params[:publication][:datasource]
    sourceid = params[:publication][:sourceid]
    publication = {}

    if !ImportManager.datasource_valid?(datasource: datasource)
      error_msg(ErrorCodes::OBJECT_ERROR, "Given datasource is not configured: #{datasource}")
      render_json
      return
    end

    case datasource
    when "none"
      #do nothing
    else
      item = ImportManager.find(datasource: datasource, sourceid: sourceid)
      if item && item.errors.messages.empty?
        publication.merge!(item.json_data)
      else
        error_msg(ErrorCodes::VALIDATION_ERROR, "Identifikatorn #{sourceid} hittades inte i #{datasource}")
        render_json
        return
      end
    end

    # Check publication identifiers for possible duplications
    publication_identifiers = publication[:publication_identifiers] || []
    publication_identifier_duplicates = []
    
    publication_identifiers.each do |publication_identifier|
      duplicates = PublicationIdentifier.where(identifier_code: publication_identifier[:identifier_code], identifier_value: publication_identifier[:identifier_value]).select(:publication_version_id)
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

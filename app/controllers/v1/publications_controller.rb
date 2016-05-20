require 'pp'

class V1::PublicationsController < V1::V1Controller

  api :GET, '/publications/:id', 'Returns a single publication based on pubid.'
  description "Returns a single complete publication object based on pubid. The most recent version of the publication is the one returned."
  def show
    id = params[:id]
    version_id = params[:version_id]
    publication = Publication.find_by_id(id)
    if publication.present? && publication.published_at.nil?
      if !publication.current_version.updated_by.eql?(@current_user.username)
        publication = nil
      end
    end
    if publication.present?
      if(version_id)
        publication_version = publication.publication_versions.where(id: version_id).first
        if(!publication_version)
          error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "publications.errors.not_found"}: #{params[:id]}")
          render_json
          return
        end
      else
        publication_version = publication.current_version
      end
      @response[:publication] = publication.as_json(version: publication_version)
      @response[:publication][:authors] = people_for_publication(publication_version_id: publication_version.id)
      authors_from_import = []
      if @response[:publication][:authors].empty? && publication_version.xml.present? && !publication_version.xml.nil?
        # Do the authorstring
        xml = Nokogiri::XML(publication_version.xml).remove_namespaces!
        datasource = publication_version.datasource
        if datasource.nil?
          # Do nothing
        elsif datasource.eql?("gupea")
          authors_from_import += Gupea.authors(xml)
        elsif  datasource.eql?("pubmed")
          authors_from_import += Pubmed.authors(xml)
        elsif  datasource.eql?("scopus")
          authors_from_import += Scopus.authors(xml)
        elsif  datasource.eql?("scigloo")
          authors_from_import += Scigloo.authors(xml)
        elsif  datasource.eql?("libris")
          authors_from_import += Libris.authors(xml)
        end
      end
      if publication_version.publication_type.blank? && publication_version.xml.present? && !publication_version.xml.nil?
        # Do the authorstring
        xml = Nokogiri::XML(publication_version.xml).remove_namespaces!
        datasource = publication_version.datasource
        if datasource.nil?
          # Do nothing
        elsif datasource.eql?("gupea")
          publication_type_suggestion = Gupea.publication_type_suggestion(xml)
        elsif  datasource.eql?("pubmed")
          publication_type_suggestion = Pubmed.publication_type_suggestion(xml)
        elsif  datasource.eql?("scopus")
          publication_type_suggestion = Scopus.publication_type_suggestion(xml)
        elsif  datasource.eql?("scigloo")
          publication_type_suggestion = Scigloo.publication_type_suggestion(xml)
        elsif  datasource.eql?("libris")
          publication_type_suggestion = Libris.publication_type_suggestion(xml)
        end
      end
      @response[:publication][:authors_from_import] = authors_from_import
      @response[:publication][:publication_type_suggestion] = publication_type_suggestion
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "publications.errors.not_found"}: #{params[:id]}")
    end
    render_json
  end

  api :DELETE, '/publications/:pubid'
  desc 'Deletes a given publication based on pubid. Only effective on draft publications.'
  def destroy 
    id = params[:id]
    publication = Publication.find_by_id(id)
    if !publication.present?
      error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "publications.errors.not_found"}: #{params[:id]}")
      render_json
      return
    end
    if publication.published_at && !@current_user.has_right?('delete_published')
      error_msg(ErrorCodes::PERMISSION_ERROR, "#{I18n.t "publications.errors.cannot_delete_published"}")
      render_json
      return
    end
    if publication.update_attribute(:deleted_at, DateTime.now)
      render_json
    else
      error_msg(ErrorCodes::VALIDATION_ERROR,"#{I18n.t "publications.errors.delete_error"}: #{params[:id]}")
      render_json
    end

  end


  private

  def publication_identifier_permitted_params(params)
    params.require(:publication_identifier).permit(:publication_version_id, :identifier_code, :identifier_value)
  end

  def create_publication_identifiers(publication_version: publication_version)
    if params[:publication][:publication_identifiers]
      pis_errors = []
      params[:publication][:publication_identifiers].each do |publication_identifier|
        publication_identifier[:publication_version_id] = publication_version.id
        pi = PublicationIdentifier.new(publication_identifier_permitted_params(ActionController::Parameters.new(publication_identifier: publication_identifier)))
        if !pi.save
          pis_errors << [pi.errors]
        end
      end
      if !pis_errors.empty?
        error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "publication_identifiers.errors.create_error"}", pis_errors)
        error = true
        raise ActiveRecord::Rollback
      end
    end 

  end
  
  # Returns collection of people including departments for a specific Publication
  def people_for_publication(publication_version_id:)
    p2ps = People2publication.where(publication_version_id: publication_version_id)
    people = p2ps.map do |p2p|
      person = Person.where(id: p2p.person_id).first.as_json
      department_ids = Departments2people2publication.where(people2publication_id: p2p.id).order(updated_at: :desc).select(:department_id)
      
      departments = Department.where(id: department_ids)
      person['departments'] = departments.as_json

      presentation_string = Person.where(id: p2p.person_id).first.presentation_string(departments.map{|d| I18n.locale == :en ? d.name_en : d.name_sv}.uniq[0..1])
      person['presentation_string'] = presentation_string

      person
    end

    return people
  end

end

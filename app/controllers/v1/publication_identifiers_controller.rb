class V1::PublicationIdentifiersController < ApplicationController

  before_filter :check_publication, :only => [:index, :create]
  
  def create
    publication_identifier = PublicationIdentifier.new(permitted_params(params))
    if !publication_identifier.save!
      generate_error(422, "#{I18n.t "publication_identifiers.errors.could_not_create"}", publication_identifier.errors)
      render_json
      return
    else
      @response[:publication_identifier] = publication_identifier
    end

    render_json
  end

  private

  def check_publication
    if params[:publication_identifier][:publication_id].nil? || params[:publication_identifier][:publication_id] == ''
      generate_error(404, "#{I18n.t "publication_identifiers.errors.publication_id_not_given"}")
      render_json
      return
    end

    publication = Publication.where(is_deleted: false).find_by_pubid(params[:publication_identifier][:publication_id])

    if !publication
      generate_error(404, "#{I18n.t "publication_identifiers.errors.publication_not_found"}")
      render_json
      return
    end
  end

  def permitted_params(params)
    params.require(:publication_identifier).permit(:publication_id, :identifier_code, :identifier_value)
  end


end

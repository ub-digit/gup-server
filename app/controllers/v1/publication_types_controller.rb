class V1::PublicationTypesController < ApplicationController
  api!
  def index
    publication_types = PublicationType.all
    @response[:publication_types] = publication_types
    render_json
  end

  api!
  def show
    publication_type = PublicationType.find_by_code(params[:id])
    if publication_type.present?
      @response[:publication_type] = publication_type
    else
      generate_error(404, "#{I18n.t "publication_types.errors.not_found"}: #{params[:id]}")
    end
    render_json
  end
end

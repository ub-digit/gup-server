class V1::PublicPublicationListsController < ApplicationController
  include PaginationHelper

  api :GET, '/publication_lists', 'Returns a list of published publications based on filter parameters'
  def index
    publications = Publication.all
    
    # Default sort order
    order = "publications.updated_at desc"

    publications = publications.non_deleted.published
    @response = generic_pagination(resource: publications, resource_name: 'publications', page: params[:page], additional_order: order, options: {include_authors: true, brief: true})
    render_json(200)

  end
end
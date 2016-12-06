class V1::PublicPublicationListsController < ApplicationController
  include PaginationHelper

  api :GET, '/publication_lists', 'Returns a list of published publications based on filter parameters'
  def index
    publications = Publication.all
    
    # Get sort order params
    sort_by = params[:sort_by] || ''
    if sort_by.eql?("pubyear")
      order = "publication_versions.pubyear desc, publications.updated_at desc"
    elsif sort_by.eql?("title")
      order = "publication_versions.title asc, publications.updated_at desc"
    else
      # pubyear should be default sort order
      order = "publications.updated_at desc"
    end
    # This join is made just for get the sort fields
    publications = Publication.joins(:current_version)

    publications = publications.non_deleted.published
    @response = generic_pagination(resource: publications, resource_name: 'publications', page: params[:page], additional_order: order, options: {include_authors: true, brief: true})
    render_json(200)

  end
end
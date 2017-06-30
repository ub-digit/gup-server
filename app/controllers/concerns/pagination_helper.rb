module PaginationHelper
  # Generic pagination generator that expects up to three inputs:
  #  - resource: ActiveRelation that responds to .paginate
  #  - page: Integer of the currently requested page (Optional; Default == 1)
  #  - per_page: Integer of results per page (Optional; Default == 10)
  # It will output a Hash with pagination data
  def generic_pagination(resource:, page: 1, per_page: 20, resource_name:, additional_order: nil, options: {})
    result = {}
    metaquery = {}
    #metaquery[:query] = params[:query] # Not implemented yet

    metaquery[:total] = resource.count

    if additional_order.nil?
      resource = resource.order(:id).reverse_order
    else
      resource = resource.order(additional_order)
    end

    result[:meta] = {}
    result[:meta][:query] = metaquery

    pagination = {}
    if !resource.empty?
      tmp = resource.paginate(page: page, per_page: per_page)
      if tmp.current_page > tmp.total_pages
        resource = resource.paginate(page: 1, per_page: per_page)
      else
        resource = tmp
      end
      pagination[:pages] = resource.total_pages
      pagination[:page] = resource.current_page
      pagination[:next] = resource.next_page
      pagination[:previous] = resource.previous_page
      pagination[:per_page] = resource.per_page
    else
      pagination[:pages] = 0
      pagination[:page] = 0
      pagination[:next] = nil
      pagination[:previous] = nil
      pagination[:per_page] = nil
    end

    result[:meta][:pagination] = pagination
    result[resource_name.to_sym] = resource.as_json(options)

    return result
  end
end

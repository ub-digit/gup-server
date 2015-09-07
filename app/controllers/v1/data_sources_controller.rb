class V1::DataSourcesController < V1::V1Controller

  api :GET, '/data_sources', 'Returns a list of all available data sources'
  def index
    @response[:data_sources] = DataSource.all
    render_json
  end
end

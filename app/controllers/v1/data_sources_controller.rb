class V1::DataSourcesController < ApplicationController

  api!
  def index
    @response[:data_sources] = DataSource.all
    render_json
  end
end

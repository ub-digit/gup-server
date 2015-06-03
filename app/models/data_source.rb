class DataSource

  def self.all
    if APP_CONFIG['data_sources']
      return APP_CONFIG['data_sources']
    else
      return []
    end
  end
end

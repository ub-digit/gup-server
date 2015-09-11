class Serie
  def self.as_json
    File.read("#{Rails.root}/config/series.json")
  end
end

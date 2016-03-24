class Serie
  def self.as_json
    File.read("#{Rails.root}/config/series.json")
  end
  
  def self.find_by_id(id)
    JSON.parse(Serie.as_json)["series"].select {|x| x["id"] == idi.to_s}.first
  end

  def self.find_by_ids(ids)
    array = ids.map(&:to_s)
    series = JSON.parse(Serie.as_json)["series"]
    selected = series.select {|x| array.include? x["id"]}

    return selected
  end
end

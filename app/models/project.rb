class Project
  def self.as_json
    File.read("#{Rails.root}/config/projects.json")
  end

  def self.find_by_id(id)
    JSON.parse(Project.as_json)["projects"].select {|x| x["id"] == idi.to_s}.first
  end

  def self.find_by_ids(ids)
    array = ids.map(&:to_s)
    projects = JSON.parse(Project.as_json)["projects"]
    selected = projects.select {|x| array.include? x["id"]}

    return selected
  end
end

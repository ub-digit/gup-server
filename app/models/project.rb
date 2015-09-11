class Project
  def self.as_json
    File.read("#{Rails.root}/config/projects.json")
  end
end

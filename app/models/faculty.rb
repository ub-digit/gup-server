# Contains languages for language selection for a publication
class Faculty

  # Returns a list of all faculties
  def self.all
    faculties = []
    APP_CONFIG['faculties'].each do |faculty|
      faculties << {name: faculty[I18n.locale.to_s + '_name'], id: faculty['id'].to_i}
    end
    return faculties
  end

  
  def self.find_by_id(id)
    self.all.find { |f| f[:id] == id.to_i }
  end
  
  def self.name_by_id(id)
    if id.blank?
      return I18n.t('faculty.unspecified')
    end
    
    faculty = Faculty.find_by_id(id)
    if faculty.blank?
      return I18n.t('faculty.not_found')
    end
      
    return faculty[:name]
  end
end

# Contains languages for language selection for a publication
class Faculty

  # Returns a list of all faculties
  def self.all
    faculties = []
    APP_CONFIG['faculties'].each do |faculty|
      faculties << {name: faculty[I18n.locale.to_s + '_name'], id: faculty['id']}
    end
    return faculties
  end

end

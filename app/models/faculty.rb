# Contains languages for language selection for a publication
class Faculty < ActiveRecord::Base

  def name
    self.send('name_' + I18n.locale.to_s)
  end

  def as_json options={}
    super.merge({
      name: name
    })
  end

  def self.name_by_id(id=nil)
    if id.blank?
      return I18n.t('faculty.unspecified')
    end
    
    faculty = Faculty.find_by_id(id)
    if faculty.blank?
      return I18n.t('faculty.not_found')
    end
      
    return faculty.name
  end
end

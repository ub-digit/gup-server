# Contains languages for language selection for a publication
class Language

  # Returns a list of all languages
  def self.all
    languages = []
    APP_CONFIG['languages'].each do |lang|
      languages << {label: lang[I18n.locale.to_s], value: lang['code']}
    end
    return languages
  end

  # Returns a single language object based on code, i.e. 'en', 'sv'
  def self.find_by_code(code)
    lang = APP_CONFIG['languages'].find{|x| x['code'] == code}
    if lang.present?
      return {label: lang[I18n.locale.to_s], value: lang['code']}
    else
      return nil
    end
  end

  # Returns all available language codes
  def self.all_codes
    APP_CONFIG['languages'].map{|x| x['code']}
  end

end

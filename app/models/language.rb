# Contains languages for language selection for a publication
class Language

  # Returns a list of all languages
  def self.all
    languages = []
    APP_CONFIG['languages'].each do |lang|
      languages << {label: lang[I18n.locale.to_s], value: lang['code'].downcase}
    end
    return languages
  end

  # Returns a single language object based on code, i.e. 'en', 'sv'
  def self.find_by_code(code)
    return nil if code.nil?
    lang = APP_CONFIG['languages'].find{|x| x['code'].downcase == code.downcase}
    if lang.present?
      return {label: lang[I18n.locale.to_s], value: lang['code'].downcase}
    else
      return nil
    end
  end

  # Returns all available language codes
  def self.all_codes
    APP_CONFIG['languages'].map{|x| x['code'].downcase}
  end

  # Returns a valid two char code for given language, if it exists
  def self.language_code_map(language)
    if APP_CONFIG['language_code_map'].has_key? (language)
      return APP_CONFIG['language_code_map'][language]
    else
      if language.blank?
        return 'en'
      else
        return language
      end
    end
  end

end

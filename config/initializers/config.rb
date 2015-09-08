if Rails.env != 'test'
  I18n.config.available_locales = [:sv, :en]
  I18n.default_locale = :sv
end

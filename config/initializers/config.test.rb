if Rails.env == 'test'
  Rails.application.config.roles = [
    {
      name: "ADMIN"
    },
    {
      name: "USER"
    }
  ]
  Rails.application.config.services = {
    session: {
      auth: "http://login-server.test.com"
    }
  }
  Rails.application.config.datasources = {
    gupea: {    
      apikey: ''  
    },
    scopus: {
      apikey: '1122334455'
    },
    crossref: {
      apikey: 'foo:foobar'
    },
    pubmed: {
      apikey: ''
    }
  }
  I18n.config.available_locales = [:sv, :en]
  I18n.default_locale = :sv  
end

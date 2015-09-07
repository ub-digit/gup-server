if Rails.env == 'test'
  Rails.application.config.roles = [
    {
      name: "ADMIN"
    },
    {
      name: "USER"
    },
    {
      name: "API_KEY"
    }
  ]
  Rails.application.config.api_key_users = [
    username: "test_key_user",
    first_name: "Test",
    last_name: "Key User",
    role: "API_KEY",
    api_key: "test-key"
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

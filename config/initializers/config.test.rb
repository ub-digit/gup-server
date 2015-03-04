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
    publication: {
      site: "http://publication-url.test.com"
    },
    session: {
      auth: "http://login-server.test.com"
    }
  }
end

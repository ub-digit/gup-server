module Requests
  module JsonHelpers
    def json
      unless @last_response_body === response.body
        @json = nil
      end
      @last_response_body = response.body
      @json ||= JSON.parse(response.body)
    end
  end

  module ConfigHelpers
    def setup_config
      Rails.application.config.roles = [
        {
          name: "ADMIN"
        },
        {
          name: "USER"
        }
      ]
    end
  end
end

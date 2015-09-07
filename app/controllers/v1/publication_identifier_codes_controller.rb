class V1::PublicationIdentifierCodesController < ApplicationController

  def index
    @response[:publication_identifier_codes] = APP_CONFIG['publication_identifier_codes'];
    render_json
  end
end

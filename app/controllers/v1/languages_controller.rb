class V1::LanguagesController < ApplicationController

  def index
    @response[:languages] = Language.all
    render_json
  end
end

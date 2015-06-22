class V1::LanguagesController < ApplicationController

  api :GET, '/languages', 'Returns a list of all languages available to assign to a publication.'
  def index
    @response[:languages] = Language.all
    render_json
  end
end

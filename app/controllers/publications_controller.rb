class PublicationsController < ApplicationController

  def index
    publications = Publication.all
    render json: {publications: publications}
  end

end

class V1::UserdataController < ApplicationController
  include PublicationsControllerHelper

  def show
    review_count = publications_for_review_by_actor(person_id: params[:id], count_only: true)
    @response[:userdata] = {
      counts: {
        review: review_count
      }
    }

    render_json
  end
end

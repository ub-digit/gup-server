require 'rails_helper'

RSpec.describe V1::PublicationIdentifiersController, type: :controller do

  describe "index" do

  end

  describe "create" do
    context "a valid publication_identifier" do
      it "should return status 200" do
        publication = create(:publication)
        publication_id = publication.pubid
        identifier_code = APP_CONFIG['publication_identifier_codes'].first['code']

        post :create, publication_identifier: {publication_id: publication_id, identifier_code: identifier_code, identifier_value: '123456'}, api_key: @api_key

        expect(response.status).to eq 200
      end
    end

    context "an invalid publication_id" do
      it "should return status 404" do
        publication_id = -1
        identifier_code = APP_CONFIG['publication_identifier_codes'].first['code']

        post :create, publication_identifier: {publication_id: publication_id, identifier_code: identifier_code, identifier_value: '123456'}, api_key: @api_key

        expect(response.status).to eq 404
      end
    end
  end
end

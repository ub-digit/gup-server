require 'rails_helper'

RSpec.describe V1::FeedbackMailsController, type: :controller do

  describe "create" do
    context "missing parameter message" do
      it "should return an error message" do
        post :create, feedback_mail: {from: 'test'}, api_key: @api_key

        expect(response.status).to eq 404
        expect(json['error']).to_not be nil
      end
    end
    context "with all parameters present" do
      it "should return a success message" do
        post :create, feedback_mail: {from: 'testuser', message: 'Testmessage', publication_id: 123}, api_key: @api_key

        expect(response.status).to eq 200
        expect(json['feedback_mail']['status']).to eq "ok"
      end
    end
  end
end

require 'rails_helper'

RSpec.describe V1::MessagesController, type: :controller do

  describe "create" do
    context "for a valid news message" do
      it "should return created message and delete any old news messages" do
        news_message = create(:news_message)
        post :create, message: {message_type: 'NEWS', message: 'Testmessage', start_date: Date.today},api_key: @api_key

        expect(response.status).to eq 201
        news_message = news_message.reload
        expect(news_message.deleted_at).to_not be nil
      end
    end
    context "for a valid alert message" do
      it "should return created message and delete any old alert messages" do
        alert_message = create(:alert_message)
        post :create, message: {message_type: 'ALERT', message: 'Testmessage', start_date: Date.today},api_key: @api_key

        expect(response.status).to eq 201
        alert_message = alert_message.reload
        expect(alert_message.deleted_at).to_not be nil
      end
    end
  end

  describe "show" do
    context "for present news article" do
      it "should return the current news message if one exists" do
        news_message = create(:news_message, message: 'news1')

        get :show, message_type: 'NEWS', api_key: @api_key

        expect(json['message']['message']).to eq 'news1'
      end
    end
    context "for present alert article" do
      it "should return the current alert message if one exists" do
        alert_message = create(:alert_message, message: 'alert1')

        get :show, message_type: 'ALERT', api_key: @api_key

        expect(json['message']['message']).to eq 'alert1'
      end
    end
    context "for an outdated alert article" do
      it "should not return any article" do
        alert_message = create(:alert_message, end_date: Date.today)

        get :show, message_type: 'ALERT', api_key: @api_key

        expect(response.status).to eq 200
        expect(json['message']['message']).to be nil
      end
    end
  end

  describe "delete" do
    context "for a news article" do
      it "should delete any existing news articles" do
        create(:news_message)

        delete :destroy, message_type: 'NEWS', api_key: @api_key

        expect(json['message']).to eq 'ok'
        expect(Message.where(deleted_at: nil).count).to eq 0
      end
    end
  end
end

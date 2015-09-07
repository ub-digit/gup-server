require 'rails_helper'

RSpec.describe V1::DataSourcesController, type: :controller do
  
  describe "get index" do
    context "for existing sources" do
      it "should return a list of sources" do
        get :index, api_key: @api_key

        expect(json['data_sources']).to_not be nil
        expect(json['data_sources'][0]['code']).to eq 'first'
      end
    end
  end
end

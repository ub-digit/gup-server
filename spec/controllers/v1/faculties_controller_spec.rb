require 'rails_helper'

RSpec.describe V1::FacultiesController, type: :controller do
  describe "index" do
    it "should return a list of faculties" do    
      create_list(:faculty, 10)

      get :index, api_key: @api_key
      
      expect(json["faculties"]).to_not be nil
      expect(json["faculties"]).to be_an(Array)
      expect(json["faculties"].count).to eq 10
    end
  end
end

require 'rails_helper'

RSpec.describe V1::PublicationTypesController, type: :controller do

  describe "index" do
    it "should return a list of publication types" do    
      create_list(:publication_type, 3)

      get :index
      
      expect(json["publication_types"]).to_not be nil
      expect(json["publication_types"]).to be_an(Array)
      expect(json["publication_types"].count).to eq 3
    end
  end

  describe "show" do
    it "should return a publication type for an existing id" do     
      create(:publication_type, id: 123)

      get :show, id: 123
      
      expect(json["publication_type"]).to_not be nil
      expect(json["publication_type"]).to be_an(Hash)
    end

    it "should return an error message for a non existing id" do
      get :show, id: 0
      
      expect(json["error"]).to_not be nil
    end
  end
end

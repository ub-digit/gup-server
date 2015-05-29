require 'rails_helper'

RSpec.describe V1::PublicationTypesController, type: :controller do

  describe "index" do
    it "should return a list of publication types" do    
      get :index 
      
      expect(json["publication_types"]).to_not be nil
      expect(json["publication_types"]).to be_an(Array)
      expect(json["publication_types"].count).to eq 3
    end
  end

  describe "show" do
    it "should return a publication type for an existing code" do     
      get :show, id: 'journal-articles'
      
      expect(json["publication_type"]).to_not be nil
      expect(json["publication_type"]).to be_an(Hash)
    end
    it "should return an error message for a no existing id" do
      get :show, id: 'non-existing-type'
      
      expect(json["error"]).to_not be nil
    end
  end
end

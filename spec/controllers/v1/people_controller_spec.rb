require 'rails_helper'

RSpec.describe V1::PeopleController, type: :controller do
  describe "index" do
    context "without any parameter" do
      it "should return a list of all people without parameters" do
        create_list(:person, 10)

        get :index 

        expect(json["people"]).to_not be nil
        expect(json["people"]).to be_an(Array)
      end
    end
    context "with parameter search_terms=xaaaaa" do
      it "should return a list of people" do
        create_list(:person, 10)

        get :index, search_term: 'xaaaaa'

        expect(json["people"]).to_not be nil
        expect(json["people"]).to be_an(Array)
      end
    end
  end

  describe "show" do
    it "should return a person for an existing id" do
      create(:person, id: 1)

      get :show, id: 1

      expect(json["person"]).to_not be nil
      expect(json["person"]).to be_an(Hash)
    end

    it "should return an error message for a no existing id" do
      get :show, id: 999
      expect(json["error"]).to_not be nil
    end
  end

  describe "create" do 
    context "with valid parameters" do
      it "should return created person" do 
        post :create, person: {first_name: "Nisse", last_name: "Hult", year_of_birth: "1917"}

        expect(json["person"]).to_not be nil
        expect(json["person"]).to be_an(Hash)
      end
    end
    context "with invalid parameters" do
      it "should return an error message" do
        put :create, person: {first_name: "Nisse", last_name: "", year_of_birth: "1918"}

        expect(json["error"]).to_not be nil
      end
    end  
  end

  describe "update" do
    context "for an existing person" do
      context "with valid parameters" do
        it "should return updated publication" do
          create(:person, id: 10)

          put :update, id: 10, person: {first_name: "Nisse", last_name: "Bult", year_of_birth: "1918"}

          expect(json["person"]).to_not be nil
          expect(json["person"]["first_name"]).to eq "Nisse"
          expect(json["person"]).to be_an(Hash)
        end
      end
      context "with invalid parameters" do
        it "should return an error message" do
          put :update, id: 10, person: {first_name: "Nisse", last_name: "", year_of_birth: "1918"}

          expect(json["error"]).to_not be nil
        end
      end
    end
    context "for a non existing person" do
      it "should return an error message" do
        put :update, id: 9999, person: {first_name: "Nisse", last_name: "Bult", year_of_birth: "1918"}
        
        expect(json["error"]).to_not be nil
      end
    end 
  end
end

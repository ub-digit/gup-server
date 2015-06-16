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

    context "with search parameters" do
      # Name search
      context "with searching on an existing first name" do
        it "should return a list of 1 person" do
          person = create(:person, first_name: "Test", last_name: "Person", affiliated: true)

          get :index, search_term: 'Test'

          expect(json["people"]).to_not be nil
          expect(json["people"].size).to be 1
          expect(json["people"][0]["first_name"]).to eq "Test"
          expect(json["people"][0]["last_name"]).to eq "Person"
        end

        it "should return a presentation string on the form 'first_name last_name, year_of_birth (affiliation 1, affiliation 2)'" do
          person = create(:person, first_name: "Test", last_name: "Person", year_of_birth: 1980, affiliated: true)

          publication = create(:publication)

          department1 = create(:department, name_sv: "department 1")
          department2 = create(:department, name_sv: "department 2")
          department3 = create(:department, name_sv: "department 3")

          people2publication = create(:people2publication, publication: publication, person: person)

          departments2people2publication1 = create(:departments2people2publication, people2publication: people2publication, department: department1)
          departments2people2publication2 = create(:departments2people2publication, people2publication: people2publication, department: department2)
          departments2people2publication3 = create(:departments2people2publication, people2publication: people2publication, department: department3)

          get :index, search_term: 'Test'

          expect(json["people"]).to_not be nil
          expect(json["people"][0]["presentation_string"]).to eq "Test Person, 1980 (department 1, department 2)"
        end
      end

      context "with searching on an existing last name" do
        it "should return a list of 1 person" do
          person = create(:person, first_name: "Test", last_name: "Person", affiliated: true)

          get :index, search_term: 'Test'

          expect(json["people"]).to_not be nil
          expect(json["people"].size).to be 1
          expect(json["people"][0]["first_name"]).to eq "Test"
          expect(json["people"][0]["last_name"]).to eq "Person"
        end
      end

      # Alternative name search
      context "with searching on an existing alternative last name" do
        it "should return a list of 1 person" do
          person = create(:person, first_name: "Test", last_name: "Person", affiliated: true)
          alternative_name = create(:alternative_name, person: person, last_name: "Altperson")

          get :index, search_term: 'Altp'

          expect(json["people"]).to_not be nil
          expect(json["people"].size).to be 1
          expect(json["people"][0]["first_name"]).to eq "Test"
          expect(json["people"][0]["last_name"]).to eq "Person"
        end
      end
      context "with searching on an existing alternative first name" do
        it "should return a list of 1 person" do
          person = create(:person, first_name: "Test", last_name: "Person", affiliated: true)
          alternative_name = create(:alternative_name, person: person, last_name: "Altfirstname")

          get :index, search_term: 'Altf'

          expect(json["people"]).to_not be nil
          expect(json["people"].size).to be 1
          expect(json["people"][0]["first_name"]).to eq "Test"
          expect(json["people"][0]["last_name"]).to eq "Person"
        end
      end

      # Xaccount search
      context "with searching on an existing xaccount" do
        it "should return a list of 1 person" do
          source = create(:source, name: 'xkonto')
          person = create(:person, first_name: "Test", last_name: "Person", affiliated: true)
          identifier = create(:identifier, source: source, person: person, value: 'xaaaaa')

          get :index, search_term: 'xaaaaa'

          expect(json["people"]).to_not be nil
          expect(json["people"].size).to be 1
          expect(json["people"][0]["first_name"]).to eq "Test"
          expect(json["people"][0]["last_name"]).to eq "Person"
        end
      end

      context "with searching on a part of 2 existing xaccounts" do
        it "should return a list of 2 persons" do
          source = create(:source, name: 'xkonto')
          person = create(:person, first_name: "Test", last_name: "Person", affiliated: true)
          identifier = create(:identifier, source: source, person: person, value: 'xaaaaa')
          person = create(:person, first_name: "Test2", last_name: "Person2", affiliated: true)
          identifier = create(:identifier, source: source, person: person, value: 'xaabbb')
          get :index, search_term: 'xaa'

          expect(json["people"]).to_not be nil
          expect(json["people"].size).to be 2
        end
      end

      context "with searching on a non-existing xaccount" do
        it "should return an empty list" do
          source = create(:source, name: 'xkonto')
          person = create(:person, first_name: "Test", last_name: "Person", affiliated: true)
          identifier = create(:identifier, source: source, person: person, value: 'xaaaaa')

          get :index, search_term: 'xab'

          expect(json["people"]).to_not be nil
          expect(json["people"].size).to be 0
        end
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
      it "should return a presentation string on the form 'first_name last_name, year_of_birth'" do
        person = create(:person, first_name: "Test", last_name: "Person", year_of_birth: 1980)

        get :index, search_term: 'Test'
        post :create, person: {first_name: "Nisse", last_name: "Hult", year_of_birth: "1917"}

        expect(json["person"]).to_not be nil
        expect(json["person"]["presentation_string"]).to eq "Nisse Hult, 1917"
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

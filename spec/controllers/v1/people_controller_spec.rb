require 'rails_helper'

RSpec.describe V1::PeopleController, type: :controller do
  describe "show" do
    it "should return a person for an existing id" do
      create(:person, id: 1)

      get :show, id: 1, api_key: @api_key

      expect(json["person"]).to_not be nil
      expect(json["person"]).to be_an(Hash)
    end

    it "should return an error message for a no existing id" do
      get :show, id: 999, api_key: @api_key
      expect(json["error"]).to_not be nil
    end
  end

  describe "create" do
    context "with valid parameters" do
      it "should return created person" do
        post :create, person: {first_name: "Nisse", last_name: "Hult", year_of_birth: "1917"}, api_key: @api_key

        expect(json["person"]).to_not be nil
        expect(json["person"]).to be_an(Hash)
      end
      it "should return a presentation string on the form 'first_name last_name, year_of_birth'" do
        person = create(:person, first_name: "Test", last_name: "Person", year_of_birth: 1980)

        get :index, search_term: 'Test', api_key: @api_key
        post :create, person: {first_name: "Nisse", last_name: "Hult", year_of_birth: "1917"}, api_key: @api_key

        expect(json["person"]).to_not be nil
        expect(json["person"]["presentation_string"]).to eq "Nisse Hult, 1917"
      end
    end

    context "with invalid parameters" do
      it "should return an error message" do
        put :create, person: {first_name: "Nisse", last_name: "", year_of_birth: "1918"}, api_key: @api_key

        expect(json["error"]).to_not be nil
      end
    end
  end

  describe "update" do
    context "for an existing person" do
      context "with valid parameters" do
        it "should return updated person" do
          create(:person, id: 10)

          put :update, id: 10, person: {first_name: "Nisse", last_name: "Bult", year_of_birth: "1918"}, api_key: @api_key

          expect(json["person"]).to_not be nil
          expect(json["person"]["first_name"]).to eq "Nisse"
          expect(json["person"]).to be_an(Hash)
        end
      end
      context "with xaccount not present" do
        it "should return updated person" do
          create(:person, id: 10)
          create(:source, name: "xkonto")

          put :update, id: 10, person: {first_name: "Nisse", last_name: "Bult", year_of_birth: "1918", xaccount: 'xnisse'}, api_key: @api_key

          expect(json["person"]).to_not be nil
          expect(json["person"]["identifiers"]).to be_an(Array)
          expect(json["person"]["identifiers"][0]).to be_an(Hash)
          expect(json["person"]["identifiers"][0]['source_name']).to eq('xkonto')
          expect(json["person"]["identifiers"][0]['value']).to eq('xnisse')
          expect(json["person"]).to be_an(Hash)
        end
      end
      context "with xaccount already in place" do
        it "should return updated person with only one xaccount identifier" do
          person = create(:person, id: 10)
          source = create(:source, name: "xkonto")
          create(:identifier, source_id: source.id, person_id: person.id, value: 'xannan')

          put :update, id: 10, person: {first_name: "Nisse", last_name: "Bult", year_of_birth: "1918", xaccount: 'xnisse'}, api_key: @api_key

          expect(json["person"]).to_not be nil
          expect(json["person"]["identifiers"]).to be_an(Array)
          expect(json["person"]["identifiers"].size).to eq(1)
          expect(json["person"]["identifiers"][0]).to be_an(Hash)
          expect(json["person"]["identifiers"][0]['source_name']).to eq('xkonto')
          expect(json["person"]["identifiers"][0]['value']).to eq('xnisse')
          expect(json["person"]).to be_an(Hash)
        end
      end
      context "with orcid not present" do
        it "should return updated person" do
          create(:person, id: 10)
          create(:source, name: "orcid")

          put :update, id: 10, person: {first_name: "Nisse", last_name: "Bult", year_of_birth: "1918", orcid: '1111-2222'}, api_key: @api_key

          expect(json["person"]).to_not be nil
          expect(json["person"]["identifiers"]).to be_an(Array)
          expect(json["person"]["identifiers"][0]).to be_an(Hash)
          expect(json["person"]["identifiers"][0]['source_name']).to eq('orcid')
          expect(json["person"]["identifiers"][0]['value']).to eq('1111-2222')
          expect(json["person"]).to be_an(Hash)
        end
      end
      context "with orcid already in place" do
        it "should return updated person with only one orcid identifier" do
          person = create(:person, id: 10)
          source = create(:source, name: "orcid")
          create(:identifier, source_id: source.id, person_id: person.id, value: '2222-1111')

          put :update, id: 10, person: {first_name: "Nisse", last_name: "Bult", year_of_birth: "1918", orcid: '1111-2222'}, api_key: @api_key

          expect(json["person"]).to_not be nil
          expect(json["person"]["identifiers"]).to be_an(Array)
          expect(json["person"]["identifiers"].size).to eq(1)
          expect(json["person"]["identifiers"][0]).to be_an(Hash)
          expect(json["person"]["identifiers"][0]['source_name']).to eq('orcid')
          expect(json["person"]["identifiers"][0]['value']).to eq('1111-2222')
          expect(json["person"]).to be_an(Hash)
        end
      end
      context "with invalid parameters" do
        it "should return an error message" do
          put :update, id: 10, person: {first_name: "Nisse", last_name: "", year_of_birth: "1918"}, api_key: @api_key

          expect(json["error"]).to_not be nil
        end
      end
    end
    context "for a non existing person" do
      it "should return an error message" do
        put :update, id: 9999, person: {first_name: "Nisse", last_name: "Bult", year_of_birth: "1918"}, api_key: @api_key

        expect(json["error"]).to_not be nil
      end
    end
    context "delete person" do
      it "should not allow deletion of person with any connection to active publications" do
        person = create(:person)
        department = create(:department)
        publication = create(:publication, id: 101)
        publication_version = publication.current_version
        p2p = create(:people2publication, person: person, publication_version: publication_version)
        create(:departments2people2publication, people2publication: p2p, department: department)

        delete :destroy, id: person.id, api_key: @api_key

        check_person = Person.find_by_id(person.id)
        expect(check_person.deleted_at).to be nil
        expect(json["error"]).to_not be nil
      end

      it "should not allow deletion of a person with any connection to (only) deleted publications" do
        person = create(:person)
        department = create(:department)
        publication = create(:deleted_publication, id: 101)
        publication_version = publication.current_version
        p2p = create(:people2publication, person: person, publication_version: publication_version)
        create(:departments2people2publication, people2publication: p2p, department: department)

        delete :destroy, id: person.id, api_key: @api_key

        check_person = Person.find_by_id(person.id)
        expect(check_person.deleted_at).to be nil
        expect(json["error"]).to_not be nil
      end

      it "should allow deletion of person without any connection to active or deleted publications" do
        person = create(:person)

        delete :destroy, id: person.id, api_key: @api_key

        check_person = Person.unscoped.find_by_id(person.id)
        expect(check_person.deleted_at).to_not be nil
        expect(json["error"]).to be nil
      end
    end
  end
end

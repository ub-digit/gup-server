require 'rails_helper'

RSpec.describe V1::PublicationsController, type: :controller do
  describe "show" do
    context "for a published publication" do
      it "should return an object" do
        create(:published_publication, id: 101)

        get :show, id: 101

        expect(json["publication"]).to_not be nil
        expect(json["publication"]).to be_an(Hash)
      end
    end

    context "for a deleted publication" do
      it "should return 404" do
        pub = create(:published_publication, id: 101)
        pub.update_attribute(:deleted_at, Time.now)

        get :show, id: 101

        expect(response.status).to eq(404)
        expect(json["error"]).to_not be nil
        expect(json["publication"]).to be nil
      end
    end

    context "for a draft publication" do
      it "should return 404 unless authenticated" do
        create(:draft_publication, id: 101)

        get :show, id: 101

        expect(response.status).to eq(404)
        expect(json["error"]).to_not be nil
        expect(json["publication"]).to be nil
      end

      it "should return an object when authenticated" do
        pub = create(:draft_publication, id: 101)
        pub.current_version.update_attribute(:updated_by, "test_key_user")

        get :show, id: 101, api_key: @api_key

        expect(response.status).to eq(200)
        expect(json["error"]).to be nil
        expect(json["publication"]).to be_an(Hash)
      end
    end

    context "for a predraft publication" do
      it "should return 404 unless authenticated" do
        create(:predraft_publication, id: 101)

        get :show, id: 101

        expect(response.status).to eq(404)
        expect(json["error"]).to_not be nil
        expect(json["publication"]).to be nil
      end
    end

    context "for a postponed publication" do
      it "should return an object with postpone information" do
        create(:delayed_publication, id: 101)

        get :show, id: 101, api_key: @api_key

        expect(json["publication"]).to_not be nil
        expect(json["publication"]).to be_an(Hash)
        expect(json["publication"]['biblreview_postponed_until']).to_not be nil
      end
    end

    context "for a no existing publication" do
      it "should return an error message" do
        get :show, id: 9999, api_key: @api_key

        expect(json["error"]).to_not be nil
      end
    end

    context "with author inc department" do
      it "should return a publication" do
        person = create(:person)
        department = create(:department)
        publication = create(:published_publication, id: 101)
        publication_version = publication.current_version
        p2p = create(:people2publication, person: person, publication_version: publication_version)
        create(:departments2people2publication, people2publication: p2p, department: department)

        get :show, id: 101, api_key: @api_key

        expect(json['publication']).to_not be nil
        expect(json['publication']['authors']).to_not be nil
        expect(json['publication']['authors'][0]['id']).to eq person.id
        expect(json['publication']['authors'][0]['departments']).to_not be nil
        expect(json['publication']['authors'][0]['departments'][0]['id']).to eq department.id
      end

      it "should return a publication with an author list with presentation string on the form 'first_name last_name, year_of_birth (affiliation 1, affiliation 2)'" do
        person = create(:person, first_name: "Test", last_name: "Person", year_of_birth: 1980)
        publication = create(:published_publication, id: 101)
        publication_version = publication.current_version

        department1 = create(:department, name_sv: "department 1")
        department2 = create(:department, name_sv: "department 2")
        department3 = create(:department, name_sv: "department 3")

        people2publication = create(:people2publication, publication_version: publication_version, person: person)

        create(:departments2people2publication, people2publication: people2publication, department: department1)
        create(:departments2people2publication, people2publication: people2publication, department: department2)
        create(:departments2people2publication, people2publication: people2publication, department: department3)

        get :show, id: 101, api_key: @api_key

        expect(json["publication"]["authors"]).to_not be nil
        expect(json["publication"]["authors"][0]["presentation_string"]).to eq "Test Person, 1980 (department 1, department 2)"
      end

      it "should return a publication with an author with a department list ordered by position" do
        person = create(:person, first_name: "Test", last_name: "Person", year_of_birth: 1980)
        publication = create(:published_publication, id: 101)
        publication_version = publication.current_version

        department1 = create(:department, name_sv: "department 1")
        department2 = create(:department, name_sv: "department 2")
        department3 = create(:department, name_sv: "department 3")

        people2publication = create(:people2publication, publication_version: publication_version, person: person)

        create(:departments2people2publication, people2publication: people2publication, department: department1, position: 3)
        create(:departments2people2publication, people2publication: people2publication, department: department2, position: 2)
        create(:departments2people2publication, people2publication: people2publication, department: department3, position: 1)

        get :show, id: 101, api_key: @api_key

        expect(json["publication"]["authors"]).to_not be nil
        expect(json["publication"]["authors"][0]["departments"][0]["id"]).to eq department3.id
        expect(json["publication"]["authors"][0]["departments"][1]["id"]).to eq department2.id
        expect(json["publication"]["authors"][0]["departments"][2]["id"]).to eq department1.id
      end

    end
  end


  describe "destroy" do
    context "for a draft publication" do
      it "should return an empty hash" do
        create(:draft_publication, id: 2001)

        delete :destroy, id: 2001, api_key: @api_key

        expect(response.status).to eq(200)
        expect(json).to be_kind_of(Hash)
        expect(json.empty?).to eq true

      end
    end

    context "for a published publication" do
      it "should return error msg for standard user" do
        create(:published_publication, id: 2001)

        delete :destroy, id: 2001, api_key: @api_key

        expect(response.status).to eq(403)
        expect(json['error']).to_not be nil
      end

      it "should not return error for admin" do
        create(:published_publication, id: 2001)

        delete :destroy, id: 2001, api_key: @api_admin_key

        expect(response.status).to eq(200)
        expect(json['error']).to be nil
      end
    end

    context "for a non existing publication" do
      it "should return an error message" do
        delete :destroy, id: 9999, api_key: @api_key

        expect(json["error"]).to_not be nil
      end
    end
  end
end

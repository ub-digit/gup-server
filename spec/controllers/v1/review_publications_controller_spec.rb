require 'rails_helper'

RSpec.describe V1::ReviewPublicationsController, type: :controller do

  describe "index" do

    context "for actor with current posts for review" do
      it "should return a list of publications" do
        create_list(:publication, 5)
        publication = create(:published_publication)
        publication_version = publication.current_version
        person = create(:xkonto_person)
        people2publication = create(:people2publication, publication_version: publication_version, person: person)
        department = create(:department)
        create(:departments2people2publication, people2publication: people2publication, department: department)

        get :index, xkonto: 'xtest', list_type: 'is_actor_for_review', api_key: @xtest_key
        expect(json['publications'].count).to eq 1

      end
    end
    context "for actor with current posts already reviewed" do
      it "should return an empty list" do
        create_list(:published_publication, 5)
        publication = create(:published_publication)
        person = create(:xkonto_person)
        people2publication = create(:people2publication, publication_version: publication.current_version, person: person, reviewed_at: DateTime.now, reviewed_publication_version_id: publication.current_version.id)
        department = create(:department)
        create(:departments2people2publication, people2publication: people2publication, department: department)

        get :index, xkonto: 'xtest', list_type: 'is_actor_for_review', api_key: @api_key

        expect(json['publications'].count).to eq 0

      end
    end
  end

  describe "update" do
    context "for user without person object" do
      it "should return an error message" do
        put :update, id: 123, api_key: @api_key

        expect(json['error']).to_not be nil
        expect(response.status).to eq 404
      end
    end
    context "for id which has no relation to person" do
      it "should return an error message" do
        publication_version = create(:publication_version, id: 123)
        person = create(:xkonto_person)
        put :update, id: 123, api_key: @xtest_key

        expect(json['error']).to_not be nil
        expect(response.status).to eq 404
      end
    end
    context "for publication which is not published" do
      it "should return an error message" do
        publication = create(:draft_publication)
        person = create(:xkonto_person)

        people2publication = create(:people2publication, publication_version: publication.current_version, person: person)
        
        put :update, id: publication.current_version.id, api_key: @xtest_key

        expect(json['error']).to_not be nil
        expect(response.status).to eq 404
      end
    end
    context "for a valid version and actor" do
      it "should return a success status" do
        publication = create(:published_publication)
        person = create(:xkonto_person)
        people2publication = create(:people2publication, publication_version: publication.current_version, person: person)

        put :update, id: publication.current_version.id, api_key: @xtest_key

        expect(response.status).to eq 200
        expect(json['error']).to be nil
      end
    end
  end
end

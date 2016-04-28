require 'rails_helper'

RSpec.describe V1::BiblreviewPublicationsController, type: :controller do

  describe "index" do
    context "with unreviewed publications filtered by publication_type" do
      it "should return a non-empty list" do
        create_list(:unreviewed_publication, 3)          

        publication = create(:unreviewed_publication)
        publication_version = publication.current_version
        publication_version.update_attribute(:publication_type, 'magazine-articles')
        person = create(:xkonto_person)
        people2publication = create(:people2publication, publication_version: publication_version, person: person, reviewed_at: DateTime.now, reviewed_publication_version_id: publication_version.id)
        department = create(:department)
        create(:departments2people2publication, people2publication: people2publication, department: department)

        get :index, api_key: @api_admin_key, pubtype:'magazine-articles'

        expect(json['publications'].count).to eq 1
      end
    end
    context "with unreviewed publications filtered by pubyear" do
      it "should return a non-empty list" do
        create_list(:unreviewed_publication, 3)          

        publication = create(:unreviewed_publication)
        publication_version = publication.current_version
        publication_version.update_attribute(:pubyear, 2014)
        person = create(:xkonto_person)
        people2publication = create(:people2publication, publication_version: publication_version, person: person, reviewed_at: DateTime.now, reviewed_publication_version_id: publication_version.id)
        department = create(:department)
        create(:departments2people2publication, people2publication: people2publication, department: department)

        get :index, api_key: @api_admin_key, pubyear:2014

        expect(json['publications'].count).to eq 1
      end
    end
    context "with unreviewed publications filtered by faculty" do
      it "should return a non-empty list" do
        create_list(:unreviewed_publication, 3)          

        publication = create(:unreviewed_publication)
        publication_version = publication.current_version
        person = create(:xkonto_person)
        people2publication = create(:people2publication, publication_version: publication_version, person: person, reviewed_at: DateTime.now, reviewed_publication_version_id: publication_version.id)
        department = create(:department, faculty_id: 42)
        create(:departments2people2publication, people2publication: people2publication, department: department)

        get :index, api_key: @api_admin_key, faculty:42

        expect(json['publications'].count).to eq 1
      end
    end
    context "with unreviewed publications and no admin rights" do
      it "should return an empty list" do
        create_list(:unreviewed_publication, 3)          

        get :index, api_key: @api_key

        expect(json['publications'].count).to eq 0
      end
    end
    context "with no unreviewed publications" do
      it "should return an empty list" do
        create_list(:publication, 3)

        get :index, api_key: @api_admin_key

        expect(json['publications'].count).to eq 0
      end
    end
    context "with reviewed and unreviewed publications" do
      it "should return a list with expected number of publications" do
        create_list(:publication, 3)
        create_list(:unreviewed_publication, 2)

        get :index, api_key: @api_admin_key

        expect(json['publications'].count).to eq 2
      end
    end

    context "with delayed publications and no admin rights" do
      it "should return an empty list" do
        create_list(:delayed_publication, 3)          

        get :index, xkonto: 'xtest', list_type: 'for_biblreview', only_delayed: 'true', api_key: @api_key

        expect(json['publications'].count).to eq 0
      end
    end

    context "with delayed and no delayed publications" do
      it "should return a list with expected number of publications" do
        create_list(:publication, 3)
        create_list(:delayed_publication, 2)

        get :index, xkonto: 'xtest', list_type: 'for_biblreview', only_delayed: 'true', api_key: @api_admin_key

        expect(json['publications'].count).to eq 2
      end
    end
  end

  describe "update" do

    context "with no admin rights" do
      it "should return an error message" do
        create(:publication, id: 45687)
        
        get :update, id: 45687, api_key: @api_key

        expect(json["error"]).to_not be nil

      end
    end

    context "with invalid pubid and admin rights" do
      it "should return an error message" do
        get :update, id: 9999999, api_key: @api_admin_key

        expect(json["error"]).to_not be nil
      end
    end

    context "for a draft publication and admin rights" do
      it "should return an error message" do
        create(:draft_publication, id: 45687)

        get :update, id: 45687, api_key: @api_admin_key

        expect(json["error"]).to_not be nil
      end
    end


    context "for a valid pubid, valid publication state and admin rights" do
      it "should return a success message" do
        create(:publication, id: 45687)

        get :update, id: 45687, api_key: @api_admin_key

        expect(json["error"]).to be nil
        expect(json["publication"]).to_not be nil
      end
    end
  end
end

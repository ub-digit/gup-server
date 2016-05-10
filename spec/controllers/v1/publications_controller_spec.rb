require 'rails_helper'

RSpec.describe V1::PublicationsController, type: :controller do
  describe "show" do
    context "for an existing publication" do
      it "should return an object" do
        create(:publication, id: 101)

        get :show, id: 101, api_key: @api_key

        expect(json["publication"]).to_not be nil
        expect(json["publication"]).to be_an(Hash)
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
        publication = create(:publication, id: 101)
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
        person = create(:person, first_name: "Test", last_name: "Person", year_of_birth: 1980, affiliated: true)
        publication = create(:publication, id: 101)
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
    end
  end

  describe "set_biblreview_postponed_until" do 
    context "with no admin rights" do
      it "should return an error message" do
        create(:publication, id: 45687)
        
        get :set_biblreview_postponed_until, id: 45687, date: '2030-01-01' , api_key: @api_key

        expect(json["error"]).to_not be nil

      end
    end

    context "with invalid pubid and admin rights" do
      it "should return an error message" do
        get :set_biblreview_postponed_until, id: 9999999, date: '2030-01-01', api_key: @api_admin_key

        expect(json["error"]).to_not be nil
      end
    end

    context "for a draft publication and admin rights" do
      it "should return an error message" do
        create(:draft_publication, id: 45687)

        get :set_biblreview_postponed_until, id: 45687, date: '2030-01-01', api_key: @api_admin_key

        expect(json["error"]).to_not be nil
      end
    end


    context "invalid input params and admin rights" do
      it "should return an error message" do
        create(:publication, id: 45687)

        get :set_biblreview_postponed_until, id: 45687, date: '', api_key: @api_admin_key

        expect(json["error"]).to_not be nil
      end
    end

    context "for a valid pubid, valid publication state and admin rights" do
      it "should return a success message" do
        create(:publication, id: 45687)
        get :set_biblreview_postponed_until, id: 45687, date: '2030-01-01', api_key: @api_admin_key

        expect(json["error"]).to be nil
        expect(json["publication"]).to_not be nil
      end
    end

    context "for a valid pubid, with epub ahead of print as comment" do
      it "should set epub_ahead_of_print flag to current DateTime" do
        publication = create(:publication, id: 45687)
          
        get :set_biblreview_postponed_until, id: 45687, date: '2030-01-01', comment: 'E-pub ahead of print', api_key: @api_admin_key

        publication.reload

        expect(publication.epub_ahead_of_print).to_not be nil
      end
    end

    context "for a valid pubid, with something other than epub ahead of print as comment" do
      it "should not set epub_ahead_of_print flag" do
        publication = create(:publication, id: 45687)
          
        get :set_biblreview_postponed_until, id: 45687, date: '2030-01-01', comment: 'E-pub ahead of sprint', api_key: @api_admin_key
        publication.reload

        expect(publication.epub_ahead_of_print).to be nil
      end
    end
  end

  

  describe "fetch_import_data" do
    context "for existing pubmed" do
      before :each do
        stub_request(:get, "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=25505574&retmode=xml").
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/pubmed-25505574.xml"), :headers => {})
       end

      it "should return a publication object" do
        get :fetch_import_data, datasource: 'pubmed', sourceid: '25505574', api_key: @api_key
        expect(json['publication']).to_not be nil
        expect(json['error']).to be nil
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
        create(:publication, id: 2001)

        delete :destroy, id: 2001, api_key: @api_key

        expect(response.status).to eq(403)
        expect(json['error']).to_not be nil
      end

      it "should not return error for admin" do
        create(:publication, id: 2001)

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

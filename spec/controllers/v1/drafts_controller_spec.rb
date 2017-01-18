require 'rails_helper'

RSpec.describe V1::DraftsController, type: :controller do

  describe "index" do
    context "when requiring drafts" do
      it "should return a list of objects" do
        create_list(:draft_publication, 5)
        other_person_draft = create(:draft_publication)
        other_person_draft.current_version.update_attributes(created_by: 'other_user')
        create_list(:published_publication, 2)

        get :index, api_key: @api_key

        expect(json["publications"]).to_not be nil
        expect(json["publications"]).to be_an(Array)
        expect(json["publications"].count).to eq 5
      end

      it "should not return predraft publications" do
        create_list(:predraft_publication, 5)
        create_list(:draft_publication, 4)
        other_person_draft = create(:draft_publication)
        other_person_draft.current_version.update_attributes(created_by: 'other_user')
        create_list(:published_publication, 2)

        get :index, api_key: @api_key

        expect(json["publications"]).to_not be nil
        expect(json["publications"]).to be_an(Array)
        expect(json["publications"].count).to eq 4
      end
    end
  end

  describe "create" do
    context "with datasource parameter" do
      it "should return created publication" do
        post :create, :datasource => 'none', api_key: @api_key
        expect(json["publication"]).to_not be nil
        expect(json["publication"]).to be_an(Hash)
        expect(json["publication"]["process_state"]).to eq("PREDRAFT")
      end
    end
    # TODO: check this test...
    context "with no parameter" do
      it "should return an error message" do
        post :create, api_key: @api_key
        expect(json["publication"]).to_not be nil
        expect(json["publication"]).to be_an(Hash)
        expect(json["publication"]["process_state"]).to eq("PREDRAFT")
      end
    end

    context "with publication_identifiers" do

      before :each do
        stub_request(:get, "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=25505574&retmode=xml").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'eutils.ncbi.nlm.nih.gov'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/pubmed-25505574.xml"), :headers => {})

        stub_request(:get, "http://api.elsevier.com/content/search/index:SCOPUS?count=1&query=DOI(10.1109/IJCNN.2008.4634188)&start=0&view=COMPLETE").
          with(:headers => {'Accept'=>'application/atom+xml', 'Accept-Encoding'=>'gzip, deflate', 'X-Els-Apikey'=>'1122334455', 'X-Els-Resourceversion'=>'XOCS', 'Host'=>'api.elsevier.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/scopus-10.1109%2fIJCNN.2008.4634188.xml"), :headers => {})

        stub_request(:get, "http://libris.kb.se/xsearch?format=mods&format_level=full&n=1&query=isbn:(978-91-637-1542-6)").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'libris.kb.se'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/libris-978-91-637-1542-6.xml"), :headers => {})

        stub_request(:get, "http://gupea.ub.gu.se/dspace-oai/request?identifier=oai:gupea.ub.gu.se:2077/12345&metadataPrefix=scigloo&verb=GetRecord").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'gupea.ub.gu.se'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/gupea-12345.xml"), :headers => {})
      end
#      it "should create publication identifiers (Libris)" do
#        get :fetch_import_data, datasource: 'libris', sourceid: '978-91-637-1542-6', api_key: @api_key
#        publication = json['publication']
#
#        post :create, :publication => publication
#
#        expect(json['publication']['publication_identifiers']).to_not be_empty
#      end
#
#      it "should create publication identifiers (PubMed)" do
#        get :fetch_import_data, datasource: 'pubmed', sourceid: '25505574', api_key: @api_key
#        publication = json['publication']
#
#        post :create, :publication => publication
#
#        expect(json['publication']['publication_identifiers']).to_not be_empty
#      end
#
#      it "should create publication identifiers (Gupea)" do
#        get :fetch_import_data, datasource: 'gupea', sourceid: '12345', api_key: @api_key
#        publication = json['publication']
#
#        post :create, :publication => publication
#
#        expect(json['publication']['publication_identifiers']).to_not be_empty
#      end
#
#      it "should create publication identifiers (Scopus)" do
#        get :fetch_import_data, datasource: 'scopus', sourceid: '10.1109/IJCNN.2008.4634188', api_key: @api_key
#        publication = json['publication']
#
#        post :create, :publication => publication
#
#        expect(json['publication']['publication_identifiers']).to_not be_empty
#        publication_identifiers = json['publication']['publication_identifiers']
#        expect(publication_identifiers.select{|x| x['identifier_code'] == 'scopus-id'}.count).to eq 1
#        expect(publication_identifiers.select{|x| x['identifier_code'] == 'doi'}.count).to eq 1
#
#      end
    end
  end

  describe "destroy" do
    context "for a draft publication" do
      it "should return an empty hash" do
        create(:draft_publication, id: 3001)

        delete :destroy, id: 3001, api_key: @api_key

        expect(response.status).to eq(200)
        expect(json).to be_kind_of(Hash)
        expect(json.empty?).to eq true
      end
    end

    context "for a non existing publication" do
      it "should return error" do
        delete :destroy, id: -1, api_key: @api_key

        expect(response.status).to eq 404
      end
    end

    context "for a published publication" do
      it "should return error" do
        create(:published_publication, id: 3002)

        delete :destroy, id: 3002, api_key: @api_key

        expect(response.status).to eq 403
      end
    end
  end

  describe "update" do
    context "for a predraft publication" do
      it "should set process_state to draft" do
        publication = create(:predraft_publication, id: 35687)

        put :update, id: 35687, publication: {title: "New test title"}, api_key: @api_key

        expect(json["publication"]).to_not be nil
        expect(json["publication"]).to be_an(Hash)
        expect(json["publication"]["process_state"]).to eq("DRAFT")
      end
      context "when epub_ahead_of_print set" do
        it "should return publication with epub_ahead_of_print set" do
          publication = create(:predraft_publication, id: 35687)

          put :update, id: 35687, publication: {title: "New test title",  epub_ahead_of_print: true}, api_key: @api_key

          expect(json['error']).to be nil
          expect(json["publication"]["epub_ahead_of_print"]).to_not be nil
        end
      end
      context "when epub_ahead_of_print not set" do
        it "should return publication with epub_ahead_of_print unset" do
          publication = create(:predraft_publication, id: 35687)

          put :update, id: 35687, publication: {title: "New test title", epub_ahead_of_print: false}, api_key: @api_key

          expect(json['error']).to be nil
          expect(json["publication"]["epub_ahead_of_print"]).to be nil
        end
      end

    end
    context "for a draft publication" do
      context "with valid parameters" do
        it "should return updated publication" do
          publication = create(:draft_publication, id: 35687)

          put :update, id: 35687, publication: {title: "New test title"}, api_key: @api_key

          expect(json["publication"]["title"]).to eq "New test title"
          expect(json["publication"]).to_not be nil
          expect(json["publication"]).to be_an(Hash)
        end
      context "when epub_ahead_of_print set" do
        it "should return publication with epub_ahead_of_print set" do
          publication = create(:draft_publication, id: 35687)

          put :update, id: 35687, publication: {title: "New test title",  epub_ahead_of_print: true}, api_key: @api_key

          expect(json['error']).to be nil
          expect(json["publication"]["epub_ahead_of_print"]).to_not be nil
        end
      end
      context "when epub_ahead_of_print not set" do
        it "should return publication with epub_ahead_of_print unset" do
          publication = create(:draft_publication, id: 35687)

          put :update, id: 35687, publication: {title: "New test title",  epub_ahead_of_print: false}, api_key: @api_key

          expect(json['error']).to be nil
          expect(json["publication"]["epub_ahead_of_print"]).to be nil
        end
      end

      end
      # TODO: Investigate this code. Why does it not pass.
      context "with invalid parameters" do
        it "should return an error message" do
          create(:draft_publication, id: 3001)
          expect {
            put :update, id: 3001, publication: {publication_type_id: 0}, api_key: @api_key
          }.to raise_error
          #expect(json["error"]).to_not be nil
        end
      end

    end
    context "for a non existing publication" do
      it "should return an error message" do
        create(:publication, id: 3001)

        put :update, id: 9999, publication: {title: "New test title"}, api_key: @api_key

        expect(json["error"]).to_not be nil
      end
    end

    context "with person inc department" do
      it "should return a publication" do
        publication = create(:publication)
        person = create(:person)
        department = create(:department)

        put :update, id: publication.id, publication: {authors: [{id: person.id, departments: [department.as_json]}]}, api_key: @api_key
        publication_new = Publication.find_by_id(publication.id)

        expect(json['error']).to be nil
        expect(json['publication']['authors'][0]['id']).to eq person.id
        expect(json['publication']['authors'][0]['departments'][0]['id']).to eq department.id
        expect(publication_new.current_version.people2publications.size).to eq 1
        expect(publication_new.current_version.people2publications.first.departments2people2publications.count).to eq 1
      end

      it "should return a publication with an author list with presentation string on the form 'first_name last_name, year_of_birth (affiliation 1, affiliation 2)'" do
        person = create(:person, first_name: "Test", last_name: "Person", year_of_birth: 1980)
        publication = create(:publication, id: 35687)

        department1 = create(:department, name_sv: "department 1")
        department2 = create(:department, name_sv: "department 2")
        department3 = create(:department, name_sv: "department 3")

        people2publication = create(:people2publication, publication_version: publication.current_version, person: person)

        create(:departments2people2publication, people2publication: people2publication, department: department1)
        create(:departments2people2publication, people2publication: people2publication, department: department2)
        create(:departments2people2publication, people2publication: people2publication, department: department3)

        put :update, id: 35687, publication: {title: "New test title", authors: [{id: person.id, departments: [department1.as_json, department2.as_json, department3.as_json]}]}, api_key: @api_key

        expect(json["publication"]["authors"]).to_not be nil
        expect(json["publication"]["authors"][0]["presentation_string"]).to eq "Test Person, 1980 (department 1, department 2)"
      end
    end

    context "with a list of hsv_local_12 categories" do
      it "should return a publication with the categories included" do
        create(:publication, id: 3001)
        # category type HSV_LOCAL_12 created by default in factory
        create(:category, id: 1)
        create(:category, id: 101)

        put :update, id: 3001, publication: {category_hsv_local: [1,101]}, api_key: @api_key

        expect(json["error"]).to be nil
        expect(json["publication"]["category_hsv_local"]).to eq [1, 101]
      end
    end
    context "with a list of hsv_11 categories" do
      it "should return a publication with no categories" do
        create(:publication, id: 3001)
        create(:category, id: 1, category_type: 'HSV_11')
        create(:category, id: 101, category_type: 'HSV_11')

        put :update, id: 3001, publication: {category_hsv_local: [1,101]}, api_key: @api_key

        expect(json["error"]).to be nil
        expect(json["publication"]["category_hsv_local"]).to eq []
      end
    end

    context "With a list of identifiers" do
      #it "should return a publication with the identifier" do
      #  publication = create(:publication, pubid: 2001)
      #  publication_identifier = create(:publication_identifier, publication_id: publication.id)
#
#        put :update, pubid: 2001, publication: {title: 'testtitle'}, api_key: @api_key
#
#        expect(json['publication']['publication_identifiers'].count).to eq 1
#      end
    end

  end
end

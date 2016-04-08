require 'rails_helper'

RSpec.describe V1::PublicationsController, type: :controller do
  describe "index" do
    context "when requiring publications" do
      it "should return a list of objects" do
        create_list(:publication, 10)

        get :index, api_key: @api_key

        expect(json["publications"]).to_not be nil
        expect(json["publications"]).to be_an(Array)
      end
    end

    context "when requiring drafts" do

      it "should return a list of objects" do
        get :index, :list_type => 'drafts' , api_key: @api_key

        expect(json["publications"]).to_not be nil
        expect(json["publications"]).to be_an(Array)
      end
    end

    describe "when requiring posts for bibl review" do
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

          get :index, xkonto: 'xtest', list_type: 'for_biblreview', api_key: @api_admin_key, pubtype:'magazine-articles'

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

          get :index, xkonto: 'xtest', list_type: 'for_biblreview', api_key: @api_admin_key, pubyear:2014

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

          get :index, xkonto: 'xtest', list_type: 'for_biblreview', api_key: @api_admin_key, faculty:42

          expect(json['publications'].count).to eq 1
        end
      end
      context "with unreviewed publications and no admin rights" do
        it "should return an empty list" do
          create_list(:unreviewed_publication, 3)          

          get :index, xkonto: 'xtest', list_type: 'for_biblreview', api_key: @api_key

          expect(json['publications'].count).to eq 0
        end
      end
      context "with no unreviewed publications" do
        it "should return an empty list" do
          create_list(:publication, 3)

          get :index, xkonto: 'xtest', list_type: 'for_biblreview', api_key: @api_admin_key

          expect(json['publications'].count).to eq 0
        end
      end
      context "with reviewed and unreviewed publications" do
        it "should return a list with expected number of publications" do
          create_list(:publication, 3)
          create_list(:unreviewed_publication, 2)

          get :index, xkonto: 'xtest', list_type: 'for_biblreview', api_key: @api_admin_key

          expect(json['publications'].count).to eq 2
        end
      end
    end

    describe "when requiring delayed posts" do
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


    describe "when requiring posts for review" do
      context "for actor with current posts for review" do
        it "should return a list of publications" do
          create_list(:publication, 5)
          publication = create(:publication)
          publication_version = publication.current_version
          person = create(:xkonto_person)
          people2publication = create(:people2publication, publication_version: publication_version, person: person)
          department = create(:department)
          create(:departments2people2publication, people2publication: people2publication, department: department)

          get :index, xkonto: 'xtest', list_type: 'is_actor_for_review', api_key: @api_key
          expect(json['publications'].count).to eq 1

        end
      end
      context "for actor with current posts already reviewed" do
        it "should return an empty list" do
          create_list(:publication, 5)
          publication = create(:publication)
          person = create(:xkonto_person)
          people2publication = create(:people2publication, publication_version: publication.current_version, person: person, reviewed_at: DateTime.now, reviewed_publication_version_id: publication.current_version.id)
          department = create(:department)
          create(:departments2people2publication, people2publication: people2publication, department: department)

          get :index, xkonto: 'xtest', list_type: 'is_actor_for_review', api_key: @api_key

          expect(json['publications'].count).to eq 0

        end
      end
      context "for actor with current posts reviewed and changed without altering review data" do
        it "should return an empty list" do
          create_list(:publication, 5)
          publication = create(:publication, id: 101)
          person = create(:xkonto_person)
          people2publication = create(:people2publication, publication_version: publication.current_version, person: person, reviewed_at: DateTime.now, reviewed_publication_version_id: publication.current_version.id)
          department = create(:department)
          create(:departments2people2publication, people2publication: people2publication, department: department)
          put :publish, id: 101, publication: {authors:[{id: person.id, departments: [{id: department.id}]}], abstract: 'something else', title: 'new title'}, api_key: @api_key

          get :index, xkonto: 'xtest', list_type: 'is_actor_for_review', api_key: @api_key

          expect(json['publications'].count).to eq 0

        end
      end
      context "for actor with current posts reviewed and changed altering content type" do
        it "should return a list of publications" do
          create_list(:publication, 5)
          publication = create(:publication, id: 101)
          publication_version = publication.current_version
          publication_version.update_attribute(:content_type, 'pop')
          person = create(:xkonto_person)
          people2publication = create(:people2publication, publication_version: publication_version, person: person, reviewed_at: DateTime.now, reviewed_publication_version_id: publication_version.id)
          department = create(:department)
          create(:departments2people2publication, people2publication: people2publication, department: department)
          put :publish, id: 101, publication: {authors:[{id: person.id, departments: [{id: department.id}]}], abstract: 'something else', title: 'new title', content_type: 'vet'}, api_key: @api_key

          get :index, xkonto: 'xtest', list_type: 'is_actor_for_review', api_key: @api_key

          expect(json['publications'].count).to eq 1
          expect(json['publications'].first['diff_since_review']['content_type']).to_not be nil

        end
      end
      context "for actor with current posts reviewed and changed altering publicationtype" do
        it "should return a list of publications" do
          create_list(:publication, 5)
          publication = create(:publication, id: 101)
          publication_version = publication.current_version
          publication_version.update_attribute(:publication_type, 'journal-articles')
          person = create(:xkonto_person)
          people2publication = create(:people2publication, publication_version: publication_version, person: person, reviewed_at: DateTime.now, reviewed_publication_version_id: publication_version.id)
          department = create(:department)
          create(:departments2people2publication, people2publication: people2publication, department: department)
          
          put :publish, id: 101, publication: {authors:[{id: person.id, departments: [{id: department.id}]}], abstract: 'something else', title: 'new title', publication_type: 'magazine-articles'}, api_key: @api_key

          get :index, xkonto: 'xtest', list_type: 'is_actor_for_review', api_key: @api_key
          
          expect(json['publications'].count).to eq 1
          expect(json['publications'].first['diff_since_review']['publication_type']).to_not be nil

        end
      end
      context "for actor with current posts reviewed and changed categories" do
        it "should return a list of publications" do
          create_list(:publication, 5)
          publication = create(:publication, id: 101)
          publication_version = publication.current_version
          publication_version.update_attribute(:category_hsv_local, [101, 10101])
          person = create(:xkonto_person)
          people2publication = create(:people2publication, publication_version: publication_version, person: person, reviewed_at: DateTime.now, reviewed_publication_version_id: publication_version.id)
          department = create(:department)
          create(:departments2people2publication, people2publication: people2publication, department: department)
          
          put :publish, id: 101, publication: {authors:[{id: person.id, departments: [{id: department.id}]}], abstract: 'something else', title: 'new title', category_hsv_local: [101]}, api_key: @api_key

          get :index, xkonto: 'xtest', list_type: 'is_actor_for_review', api_key: @api_key
          
          expect(json['publications'].count).to eq 1
          expect(json['publications'].first['diff_since_review']['category_hsv_local']).to_not be nil

        end
      end
      context "for actor with current posts reviewed and changed affiliations" do
        it "should return a list of publications" do
          create_list(:publication, 5)
          publication = create(:publication, id: 101)
          publication_version = publication.current_version
          person = create(:xkonto_person)
          people2publication = create(:people2publication, publication_version: publication_version, person: person, reviewed_at: DateTime.now, reviewed_publication_version_id: publication_version.id)
          department = create(:department)
          department2 = create(:department)
          create(:departments2people2publication, people2publication: people2publication, department: department)
          
          put :publish, id: 101, publication: {authors:[{id: person.id, departments: [{id: department2.id}]}], abstract: 'something else', title: 'new title'}, api_key: @api_key

          get :index, xkonto: 'xtest', list_type: 'is_actor_for_review', api_key: @api_key
          
          expect(json['publications'].count).to eq 1
          expect(json['publications'].first['diff_since_review']['affiliation']).to_not be nil

        end
      end

      context "for actor with current posts reviewed and changed affiliations, and then affiliations changed back" do
        it "should return an empty list of publications" do
          create_list(:publication, 5)
          publication = create(:publication, id: 101)
          publication_version = publication.current_version
          person = create(:xkonto_person)
          people2publication = create(:people2publication, publication_version: publication_version, person: person, reviewed_at: DateTime.now, reviewed_publication_version_id: publication_version.id)
          department = create(:department)
          department2 = create(:department)
          create(:departments2people2publication, people2publication: people2publication, department: department)

          put :publish, id: 101, publication: {authors:[{id: person.id, departments: [{id: department2.id}]}], abstract: 'something else', title: 'new title'}, api_key: @api_key
          put :publish, id: 101, publication: {authors:[{id: person.id, departments: [{id: department.id}]}], abstract: 'something else', title: 'new title'}, api_key: @api_key

          get :index, xkonto: 'xtest', list_type: 'is_actor_for_review', api_key: @api_key
                 
          expect(json['publications'].count).to eq 0
        end
      end

      context "for actor with current posts reviewed and actor removed from publication" do
        it "should return an emoty list" do
          create_list(:publication, 5)
          publication = create(:publication, id: 101)
          publication_version = publication.current_version
          person = create(:xkonto_person)
          person2 = create(:person)
          people2publication = create(:people2publication, publication_version: publication_version, person: person, reviewed_at: DateTime.now, reviewed_publication_version_id: publication_version.id)
          department = create(:department)
          department2 = create(:department)
          create(:departments2people2publication, people2publication: people2publication, department: department)
          
          put :publish, id: 101, publication: {authors:[{id: person2.id, departments: [{id: department2.id}]}], abstract: 'something else', title: 'new title'}, api_key: @api_key

          get :index, xkonto: 'xtest', list_type: 'is_actor_for_review', api_key: @api_key

          expect(json['publications'].count).to eq 0

        end
      end
      context "for actor with current posts reviewed and changed altering content type, and then changed it back" do
        it "should return an empty list of publications" do
          create_list(:publication, 5)
          publication = create(:publication, id: 101)
          publication_version = publication.current_version
          publication_version.update_attribute(:content_type, 'pop')
          person = create(:xkonto_person)
          people2publication = create(:people2publication, publication_version: publication_version, person: person, reviewed_at: DateTime.now, reviewed_publication_version_id: publication_version.id)
          department = create(:department)
          create(:departments2people2publication, people2publication: people2publication, department: department)

          put :publish, id: 101, publication: {authors:[{id: person.id, departments: [{id: department.id}]}], abstract: 'something else', title: 'new title', content_type: 'vet'}, api_key: @api_key
          put :publish, id: 101, publication: {authors:[{id: person.id, departments: [{id: department.id}]}], abstract: 'something else', title: 'new title', content_type: 'pop'}, api_key: @api_key
          
          get :index, xkonto: 'xtest', list_type: 'is_actor_for_review', api_key: @api_key

          expect(json['publications'].count).to eq 0

        end
      end
    end
  end

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

    context "imported data" do
      before :each do
        stub_request(:get, "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=25505574&retmode=xml").
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/pubmed-25505574.xml"), :headers => {})

        stub_request(:get, "http://api.elsevier.com/content/search/index:SCOPUS?count=1&query=DOI(10.1109/IJCNN.2008.4634188)&start=0&view=COMPLETE").
          with(:headers => {'Accept'=>'application/atom+xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby', 'X-Els-Apikey'=>'1122334455', 'X-Els-Resourceversion'=>'XOCS'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/scopus-10.1109%2fIJCNN.2008.4634188.xml"), :headers => {})

        stub_request(:get, "http://libris.kb.se/xsearch?format=mods&format_level=full&n=1&query=isbn:(978-91-637-1542-6)").
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/libris-978-91-637-1542-6.xml"), :headers => {})

        stub_request(:get, "http://gupea.ub.gu.se/dspace-oai/request?identifier=oai:gupea.ub.gu.se:2077/12345&metadataPrefix=scigloo&verb=GetRecord").
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/gupea-12345.xml"), :headers => {})

        stub_request(:get, "http://solr.lib.chalmers.se:8080/solr/scigloo/select?q=*%3A*&fq=pubid%3A170399&wt=xml&indent=true").
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/scigloo-170399.xml"), :headers => {})
end
      
      context "publication type suggestion" do
        it "should return a suggested publication type (pubmed)" do
          get :fetch_import_data, datasource: 'pubmed', sourceid: '25505574', api_key: @api_key
          expect(json['publication']).to_not be nil
          expect(json['error']).to be nil

          post :create, publication: json['publication'], api_key: @api_key
          expect(json['error']).to be_nil

          get :show, id: json['publication']['id'], api_key: @api_key
          expect(json['publication']['publication_type_suggestion']).to eq("journal-articles")
        end

        it "should return a suggested publication type (scopus)" do
          get :fetch_import_data, datasource: 'scopus', sourceid: '10.1109/IJCNN.2008.4634188', api_key: @api_key
          expect(json['publication']).to_not be nil
          expect(json['error']).to be nil

          post :create, publication: json['publication'], api_key: @api_key
          expect(json['error']).to be_nil

          get :show, id: json['publication']['id'], api_key: @api_key
          expect(json['publication']['publication_type_suggestion']).to eq("conference-papers")
        end
      end

      context "authors from imported" do
        it "should return list of authors as objects from imported post (pubmed)" do
          get :fetch_import_data, datasource: 'pubmed', sourceid: '25505574', api_key: @api_key
          expect(json['publication']).to_not be nil
          expect(json['error']).to be nil

          post :create, publication: json['publication'], api_key: @api_key
          expect(json['error']).to be_nil

          get :show, id: json['publication']['id'], api_key: @api_key
          expect(json['publication']['authors_from_import']).to be_a(Array)
          expect(json['publication']['authors_from_import'][0]).to be_a(Hash)
          expect(json['publication']['authors_from_import'][0]['last_name']).to eq("Brath")
          expect(json['publication']['authors_from_import'][0]['first_name']).to eq("Ulrika")
          expect(json['publication']['authors_from_import'][0]['affiliation']).to match(/Chemistry and Molecular/)
          expect(json['publication']['authors_from_import'][0]['full_author_string']).to match(/Chemistry and Molecular/)
        end

        it "should return list of authors as objects from imported post (scigloo)" do
          get :fetch_import_data, datasource: 'scigloo', sourceid: '170399', api_key: @api_key
          expect(json['publication']).to_not be nil
          expect(json['error']).to be nil

          post :create, publication: json['publication'], api_key: @api_key
          expect(json['error']).to be_nil

          get :show, id: json['publication']['id'], api_key: @api_key
          expect(json['publication']['authors_from_import']).to be_a(Array)
          expect(json['publication']['authors_from_import'][0]).to be_a(Hash)
          expect(json['publication']['authors_from_import'][0]['last_name']).to eq("Ohlsson")
          expect(json['publication']['authors_from_import'][0]['first_name']).to eq("Claes")
          expect(json['publication']['authors_from_import'][0]['full_author_string']).to match(/Ohlsson, Claes/)
        end

        it "should return list of authors as objects from imported post (scopus)" do
          get :fetch_import_data, datasource: 'scopus', sourceid: '10.1109/IJCNN.2008.4634188', api_key: @api_key
          expect(json['publication']).to_not be nil
          expect(json['error']).to be nil

          post :create, publication: json['publication'], api_key: @api_key
          expect(json['error']).to be_nil

          get :show, id: json['publication']['id'], api_key: @api_key
          expect(json['publication']['authors_from_import']).to be_a(Array)
          expect(json['publication']['authors_from_import'][0]).to be_a(Hash)
          expect(json['publication']['authors_from_import'][0]['last_name']).to eq("Gudmundsson")
          expect(json['publication']['authors_from_import'][0]['first_name']).to match(/Steinn/)
          expect(json['publication']['authors_from_import'][0]['full_author_string']).to match(/Gudmundsson/)
          expect(json['publication']['authors_from_import'][0]['full_author_string']).to match(/Steinn/)
        end

        it "should return list of authors as objects from imported post (gupea)" do
          get :fetch_import_data, datasource: 'gupea', sourceid: '12345', api_key: @api_key
          expect(json['publication']).to_not be nil
          expect(json['error']).to be nil

          post :create, publication: json['publication'], api_key: @api_key
          expect(json['error']).to be_nil

          get :show, id: json['publication']['id'], api_key: @api_key
          expect(json['publication']['authors_from_import']).to be_a(Array)
          expect(json['publication']['authors_from_import'][0]).to be_a(Hash)
          expect(json['publication']['authors_from_import'][0]['last_name']).to eq("Kulundu Manda")
          expect(json['publication']['authors_from_import'][0]['first_name']).to eq("Damiano")
          expect(json['publication']['authors_from_import'][0]['full_author_string']).to match(/Kulundu/)
          expect(json['publication']['authors_from_import'][0]['full_author_string']).to match(/Damiano/)
        end

        it "should return list of authors as objects from imported post (libris)" do
          get :fetch_import_data, datasource: 'libris', sourceid: '978-91-637-1542-6', api_key: @api_key
          expect(json['publication']).to_not be nil
          expect(json['error']).to be nil

          post :create, publication: json['publication'], api_key: @api_key
          expect(json['error']).to be_nil

          get :show, id: json['publication']['id'], api_key: @api_key
          expect(json['publication']['authors_from_import']).to be_a(Array)
          expect(json['publication']['authors_from_import'][0]).to be_a(Hash)
          expect(json['publication']['authors_from_import'][0]['last_name']).to eq("Mossberg")
          expect(json['publication']['authors_from_import'][0]['first_name']).to eq("Lena")
          expect(json['publication']['authors_from_import'][0]['full_author_string']).to match(/Mossberg/)
          expect(json['publication']['authors_from_import'][0]['full_author_string']).to match(/Lena/)
        end
      end
    end
  end

  describe "create" do 
    context "with datasource parameter" do 
      it "should return created publication" do 
        post :create, :datasource => 'none', api_key: @api_key
        expect(json["publication"]).to_not be nil
        expect(json["publication"]).to be_an(Hash)
      end
    end
    context "with no parameter" do
      it "should return an error message" do
        post :create, api_key: @api_key
        expect(json["publication"]).to_not be nil
        expect(json["publication"]).to be_an(Hash)      
      end
    end

    context "with publication_identifiers" do
      
      before :each do
        stub_request(:get, "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=25505574&retmode=xml").
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/pubmed-25505574.xml"), :headers => {})

        stub_request(:get, "http://api.elsevier.com/content/search/index:SCOPUS?count=1&query=DOI(10.1109/IJCNN.2008.4634188)&start=0&view=COMPLETE").
          with(:headers => {'Accept'=>'application/atom+xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby', 'X-Els-Apikey'=>'1122334455', 'X-Els-Resourceversion'=>'XOCS'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/scopus-10.1109%2fIJCNN.2008.4634188.xml"), :headers => {})

        stub_request(:get, "http://libris.kb.se/xsearch?format=mods&format_level=full&n=1&query=isbn:(978-91-637-1542-6)").
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/libris-978-91-637-1542-6.xml"), :headers => {})

        stub_request(:get, "http://gupea.ub.gu.se/dspace-oai/request?identifier=oai:gupea.ub.gu.se:2077/12345&metadataPrefix=scigloo&verb=GetRecord").
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/gupea-12345.xml"), :headers => {})
      end
      it "should create publication identifiers (Libris)" do
        get :fetch_import_data, datasource: 'libris', sourceid: '978-91-637-1542-6', api_key: @api_key
        publication = json['publication']

        post :create, :publication => publication

        expect(json['publication']['publication_identifiers']).to_not be_empty
      end

      it "should create publication identifiers (PubMed)" do
        get :fetch_import_data, datasource: 'pubmed', sourceid: '25505574', api_key: @api_key
        publication = json['publication']
         
        post :create, :publication => publication

        expect(json['publication']['publication_identifiers']).to_not be_empty
      end
     
      it "should create publication identifiers (Gupea)" do
        get :fetch_import_data, datasource: 'gupea', sourceid: '12345', api_key: @api_key
        publication = json['publication']

        post :create, :publication => publication

        expect(json['publication']['publication_identifiers']).to_not be_empty
      end
      
      it "should create publication identifiers (Scopus)" do
        get :fetch_import_data, datasource: 'scopus', sourceid: '10.1109/IJCNN.2008.4634188', api_key: @api_key
        publication = json['publication']

        post :create, :publication => publication

        expect(json['publication']['publication_identifiers']).to_not be_empty
        publication_identifiers = json['publication']['publication_identifiers']
        expect(publication_identifiers.select{|x| x['identifier_code'] == 'scopus-id'}.count).to eq 1
        expect(publication_identifiers.select{|x| x['identifier_code'] == 'doi'}.count).to eq 1

      end


    end

    #context "with file parameter" do 
    # it "should return the last created publication" do 
    #
    #  post :create, :file => 'xyz'
    #
    #  expect(json["publication"]).to_not be nil
    #  expect(json["publication"]).to be_an(Hash)
    #end
  end  

  describe "update" do
    context "for an existing no deleted and published publication" do
      context "with valid parameters" do
        it "should return updated publication" do
          create(:publication, id: 45687)

          put :update, id: 45687, publication: {title: "New test title"}, api_key: @api_key 

          expect(json["publication"]["title"]).to eq "New test title"
          expect(json["publication"]).to_not be nil
          expect(json["publication"]).to be_an(Hash)
        end
      end
      context "with invalid parameters" do
        it "should return an error message" do
          create(:publication, id: 2001)

          put :update, id: 2001, publication: {publication_type: 'non-existing-type'}, api_key: @api_key

          expect(json["error"]).to_not be nil
        end
      end

    end
    context "for a non existing publication" do
      it "should return an error message" do
        create(:publication, id: 2001)

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
        person = create(:person, first_name: "Test", last_name: "Person", year_of_birth: 1980, affiliated: true)
        publication = create(:publication, id: 45687)

        department1 = create(:department, name_sv: "department 1")
        department2 = create(:department, name_sv: "department 2")
        department3 = create(:department, name_sv: "department 3")

        people2publication = create(:people2publication, publication_version: publication.current_version, person: person)

        create(:departments2people2publication, people2publication: people2publication, department: department1)
        create(:departments2people2publication, people2publication: people2publication, department: department2)
        create(:departments2people2publication, people2publication: people2publication, department: department3)

        put :update, id: 45687, publication: {title: "New test title", authors: [{id: person.id, departments: [department1.as_json, department2.as_json, department3.as_json]}]}, api_key: @api_key

        expect(json["publication"]["authors"]).to_not be nil
        expect(json["publication"]["authors"][0]["presentation_string"]).to eq "Test Person, 1980 (department 1, department 2)"
      end

      it "should set the person as affiliated" do
        publication = create(:publication)
        person = create(:person)
        department = create(:department)

        put :update, id: publication.id, publication: {authors: [{id: person.id, departments: [department.as_json]}]}, api_key: @api_key
        expect(Person.find_by_id(person.id).affiliated).to eq true    
      end    
    end

    context "With a list of categories" do
      it "should return a publication" do
        create(:publication, id: 2001)

        put :update, id: 2001, publication: {category_hsv_local: [1,101]}, api_key: @api_key

        expect(json["error"]).to be nil
        expect(json["publication"]["category_hsv_local"]).to eq [1, 101]
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

  describe "publish" do
    context "for an existing no deleted and draft publication" do
      context "with valid parameters" do
        it "should return updated publication" do
          create(:draft_publication, id: 45687)

          put :publish, id: 45687, publication: {title: "New test title"}, api_key: @api_key

          expect(json["publication"]).to_not be nil
          expect(json["publication"]).to be_an(Hash)
          expect(json["publication"]["title"]).to eq "New test title"
          expect(json["publication"]["published_at"]).to_not be nil
        end
      end
    end

    context "with person inc department" do
      it "should return a publication" do
        publication = create(:publication)
        person = create(:person)
        department = create(:department)

        put :publish, id: publication.id, publication: {authors: [{id: person.id, departments: [department.as_json]}]}, api_key: @api_key
        publication_new = Publication.find_by_id(publication.id)

        expect(json['error']).to be nil
        expect(json['publication']['authors'][0]['id']).to eq person.id
        expect(json['publication']['authors'][0]['departments'][0]['id']).to eq department.id
        expect(publication_new.current_version.people2publications.size).to eq 1
        expect(publication_new.current_version.people2publications.first.departments2people2publications.count).to eq 1
      end

      it "should return a publication with an author list with presentation string on the form 'first_name last_name, year_of_birth (affiliation 1, affiliation 2)'" do
        person = create(:person, first_name: "Test", last_name: "Person", year_of_birth: 1980, affiliated: true)
        publication = create(:publication, id: 45687)

        department1 = create(:department, name_sv: "department 1")
        department2 = create(:department, name_sv: "department 2")
        department3 = create(:department, name_sv: "department 3")

        people2publication = create(:people2publication, publication_version: publication.current_version, person: person)

        create(:departments2people2publication, people2publication: people2publication, department: department1)
        create(:departments2people2publication, people2publication: people2publication, department: department2)
        create(:departments2people2publication, people2publication: people2publication, department: department3)

        put :publish, id: 45687, publication: {title: "New test title", authors: [{id: person.id, departments: [department1.as_json, department2.as_json, department3.as_json]}]}, api_key: @api_key 

        expect(json["publication"]["authors"]).to_not be nil
        expect(json["publication"]["authors"][0]["presentation_string"]).to eq "Test Person, 1980 (department 1, department 2)"
      end
    end

    context "for an existing no deleted and published publication" do
      context "with valid parameters" do
        it "should return updated publication" do
          create(:publication, id: 45687)

          put :publish, id: 45687, publication: {title: "New test title"}, api_key: @api_key 

          expect(json["error"]).to be nil
          expect(json["publication"]).to_not be nil
        end
      end
    end

    context "for an existing no deleted, published and bibl reviewed publication" do
      context "with valid parameters" do
        it "should return updated publication with empty bibl reviewed attributes" do
          create(:publication, id: 45687)

          put :publish, id: 45687, publication: {title: "New test title"}, api_key: @api_key 

          expect(json["error"]).to be nil
          expect(json["publication"]).to_not be nil
          expect(json["publication"]["biblreviewed_at"]).to be nil
          expect(json["publication"]["biblreviewed_by"]).to be nil
        end
      end
    end

    context "for an existing no deleted, published and bibl unreviewed publication with a delay date set" do
      context "with valid parameters" do
        it "should return updated publication with reset delay parameters" do
          pub = create(:unreviewed_publication, id: 45687)
          delayed_time = DateTime.now + 2

          pub.update_attributes(biblreview_postponed_until: delayed_time, biblreview_postpone_comment: "Delayed")

          put :publish, id: 45687, publication: {title: "New test title"}, api_key: @api_key 
          expect(json["error"]).to be nil
          expect(json["publication"]).to_not be nil
          expect(json["publication"]["biblreview_postponed_until"]).to_not eq delayed_time
          expect(json["publication"]["biblreview_postponed_comment"]).to be nil
        end
      end
    end
  end

  describe "bibl_review" do 
    context "with no admin rights" do
      it "should return an error message" do
        create(:publication, id: 45687)
        
        get :bibl_review, id: 45687, api_key: @api_key

        expect(json["error"]).to_not be nil

      end
    end

    context "with invalid pubid and admin rights" do
      it "should return an error message" do
        get :bibl_review, id: 9999999, api_key: @api_admin_key

        expect(json["error"]).to_not be nil
      end
    end

    context "for a draft publication and admin rights" do
      it "should return an error message" do
        create(:draft_publication, id: 45687)

        get :bibl_review, id: 45687, api_key: @api_admin_key

        expect(json["error"]).to_not be nil
      end
    end


    context "for a valid pubid, valid publication state and admin rights" do
      it "should return a success message" do
        create(:publication, id: 45687)
        get :bibl_review, id: 45687, api_key: @api_admin_key

        expect(json["error"]).to be nil
        expect(json["publication"]).to_not be nil
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
=begin  
  describe "publications_for_review_by_actor" do
    context "for a valid person_id with publications" do
      it "should return a list of publications" do
        publication = create(:publication, pubid: 101)
        person = create(:person)
        people2publication = create(:people2publication, publication: publication, person: person)
        department = create(:department)
        create(:departments2people2publication, people2publication: people2publication, department: department)

        controller = V1::PublicationsController.new
        publications = controller.send('publications_for_review_by_actor', {person_id: person.id})

        expect(publications.count).to eq 1
        expect(publications.first['pubid']).to eq 101
        expect(publications.first['affiliation']).to_not be nil
      end
    end

    context "for a valid person_id with unaffiliated publications" do
      it "should return an empty list" do
        publication = create(:publication, pubid: 101)
        person = create(:person)
        people2publication = create(:people2publication, publication: publication, person: person)
        department = create(:department)
        #create(:departments2people2publication, people2publication: people2publication, department: department)

        controller = V1::PublicationsController.new
        publications = controller.send('publications_for_review_by_actor', {person_id: person.id})

        expect(publications.count).to eq 0
      end
    end
  end
=end
end

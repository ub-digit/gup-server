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

    describe "when requiring posts for review" do
      context "for actor with current posts for review" do
        it "should return a list of publications" do
          create_list(:publication, 5)
          publication = create(:publication, pubid: 101)
          person = create(:xkonto_person)
          people2publication = create(:people2publication, publication: publication, person: person)
          department = create(:department)
          department2people2publication = create(:departments2people2publication, people2publication: people2publication, department: department)

          get :index, xkonto: 'xtest', list_type: 'is_actor_for_review', api_key: @api_key
          expect(json['publications'].count).to eq 1

        end
      end
      context "for actor with current posts already reviewed" do
        it "should return an empty list" do
          create_list(:publication, 5)
          publication = create(:publication, pubid: 101)
          person = create(:xkonto_person)
          people2publication = create(:people2publication, publication: publication, person: person, reviewed_at: DateTime.now, reviewed_publication_id: publication.id)
          department = create(:department)
          department2people2publication = create(:departments2people2publication, people2publication: people2publication, department: department)

          get :index, xkonto: 'xtest', list_type: 'is_actor_for_review', api_key: @api_key

          expect(json['publications'].count).to eq 0

        end
      end
      context "for actor with current posts reviewed and changed without altering review data" do
        it "should return an empty list" do
          create_list(:publication, 5)
          publication = create(:publication, pubid: 101)
          person = create(:xkonto_person)
          people2publication = create(:people2publication, publication: publication, person: person, reviewed_at: DateTime.now, reviewed_publication_id: publication.id)
          department = create(:department)
          department2people2publication = create(:departments2people2publication, people2publication: people2publication, department: department)
          put :publish, pubid: 101, publication: {authors:[{id: person.id, departments: [{id: department.id}]}], abstract: 'something else', title: 'new title'}, api_key: @api_key

          get :index, xkonto: 'xtest', list_type: 'is_actor_for_review', api_key: @api_key

          expect(json['publications'].count).to eq 0

        end
      end
      context "for actor with current posts reviewed and changed altering content type" do
        it "should return a list of publications" do
          create_list(:publication, 5)
          publication = create(:publication, pubid: 101, content_type: 'pop')
          person = create(:xkonto_person)
          people2publication = create(:people2publication, publication: publication, person: person, reviewed_at: DateTime.now, reviewed_publication_id: publication.id)
          department = create(:department)
          department2people2publication = create(:departments2people2publication, people2publication: people2publication, department: department)
          put :publish, pubid: 101, publication: {authors:[{id: person.id, departments: [{id: department.id}]}], abstract: 'something else', title: 'new title', content_type: 'vet'}, api_key: @api_key

          get :index, xkonto: 'xtest', list_type: 'is_actor_for_review', api_key: @api_key

          expect(json['publications'].count).to eq 1
          expect(json['publications'].first['diff_since_review']['content_type']).to_not be nil

        end
      end
      context "for actor with current posts reviewed and changed altering publicationtype" do
        it "should return a list of publications" do
          create_list(:publication, 5)
          publication = create(:publication, pubid: 101, publication_type: 'journal-articles')
          person = create(:xkonto_person)
          people2publication = create(:people2publication, publication: publication, person: person, reviewed_at: DateTime.now, reviewed_publication_id: publication.id)
          department = create(:department)
          department2people2publication = create(:departments2people2publication, people2publication: people2publication, department: department)
          
          put :publish, pubid: 101, publication: {authors:[{id: person.id, departments: [{id: department.id}]}], abstract: 'something else', title: 'new title', publication_type: 'magazine-articles'}, api_key: @api_key

          get :index, xkonto: 'xtest', list_type: 'is_actor_for_review', api_key: @api_key
          
          expect(json['publications'].count).to eq 1
          expect(json['publications'].first['diff_since_review']['publication_type']).to_not be nil

        end
      end
      context "for actor with current posts reviewed and changed categories" do
        it "should return a list of publications" do
          create_list(:publication, 5)
          publication = create(:publication, pubid: 101, category_hsv_local: [101, 10101])
          person = create(:xkonto_person)
          people2publication = create(:people2publication, publication: publication, person: person, reviewed_at: DateTime.now, reviewed_publication_id: publication.id)
          department = create(:department)
          department2people2publication = create(:departments2people2publication, people2publication: people2publication, department: department)
          
          put :publish, pubid: 101, publication: {authors:[{id: person.id, departments: [{id: department.id}]}], abstract: 'something else', title: 'new title', category_hsv_local: [101]}, api_key: @api_key

          get :index, xkonto: 'xtest', list_type: 'is_actor_for_review', api_key: @api_key
          
          expect(json['publications'].count).to eq 1
          expect(json['publications'].first['diff_since_review']['category_hsv_local']).to_not be nil

        end
      end
      context "for actor with current posts reviewed and changed affiliations" do
        it "should return a list of publications" do
          create_list(:publication, 5)
          publication = create(:publication, pubid: 101)
          person = create(:xkonto_person)
          people2publication = create(:people2publication, publication: publication, person: person, reviewed_at: DateTime.now, reviewed_publication_id: publication.id)
          department = create(:department)
          department2 = create(:department)
          department2people2publication = create(:departments2people2publication, people2publication: people2publication, department: department)
          
          put :publish, pubid: 101, publication: {authors:[{id: person.id, departments: [{id: department2.id}]}], abstract: 'something else', title: 'new title'}, api_key: @api_key

          get :index, xkonto: 'xtest', list_type: 'is_actor_for_review', api_key: @api_key
          
          expect(json['publications'].count).to eq 1
          expect(json['publications'].first['diff_since_review']['affiliation']).to_not be nil

        end
      end

      context "for actor with current posts reviewed and changed affiliations, and then affiliations changed back" do
        it "should return an empty list of publications" do
          create_list(:publication, 5)
          publication = create(:publication, pubid: 101)
          person = create(:xkonto_person)
          people2publication = create(:people2publication, publication: publication, person: person, reviewed_at: DateTime.now, reviewed_publication_id: publication.id)
          department = create(:department)
          department2 = create(:department)
          department2people2publication = create(:departments2people2publication, people2publication: people2publication, department: department)

          put :publish, pubid: 101, publication: {authors:[{id: person.id, departments: [{id: department2.id}]}], abstract: 'something else', title: 'new title'}, api_key: @api_key
          put :publish, pubid: 101, publication: {authors:[{id: person.id, departments: [{id: department.id}]}], abstract: 'something else', title: 'new title'}, api_key: @api_key

          get :index, xkonto: 'xtest', list_type: 'is_actor_for_review', api_key: @api_key
                   
          expect(json['publications'].count).to eq 0
        end
      end

      context "for actor with current posts reviewed and actor removed from publication" do
        it "should return an emoty list" do
          create_list(:publication, 5)
          publication = create(:publication, pubid: 101)
          person = create(:xkonto_person)
          person2 = create(:person)
          people2publication = create(:people2publication, publication: publication, person: person, reviewed_at: DateTime.now, reviewed_publication_id: publication.id)
          department = create(:department)
          department2 = create(:department)
          department2people2publication = create(:departments2people2publication, people2publication: people2publication, department: department)
          
          put :publish, pubid: 101, publication: {authors:[{id: person2.id, departments: [{id: department2.id}]}], abstract: 'something else', title: 'new title'}, api_key: @api_key

          get :index, xkonto: 'xtest', list_type: 'is_actor_for_review', api_key: @api_key

          expect(json['publications'].count).to eq 0

        end
      end
      context "for actor with current posts reviewed and changed altering content type, and then changed it back" do
        it "should return an empty list of publications" do
          create_list(:publication, 5)
          publication = create(:publication, pubid: 101, content_type: 'pop')
          person = create(:xkonto_person)
          people2publication = create(:people2publication, publication: publication, person: person, reviewed_at: DateTime.now, reviewed_publication_id: publication.id)
          department = create(:department)
          department2people2publication = create(:departments2people2publication, people2publication: people2publication, department: department)

          put :publish, pubid: 101, publication: {authors:[{id: person.id, departments: [{id: department.id}]}], abstract: 'something else', title: 'new title', content_type: 'vet'}, api_key: @api_key
          put :publish, pubid: 101, publication: {authors:[{id: person.id, departments: [{id: department.id}]}], abstract: 'something else', title: 'new title', content_type: 'pop'}, api_key: @api_key
          
          get :index, xkonto: 'xtest', list_type: 'is_actor_for_review', api_key: @api_key

          expect(json['publications'].count).to eq 0

        end
      end

    end
  end

  describe "show" do
    context "for an existing publication" do
      it "should return an object" do
        create(:publication, pubid: 101)

        get :show, :pubid => 101, api_key: @api_key

        expect(json["publication"]).to_not be nil
        expect(json["publication"]).to be_an(Hash)
      end
    end

    context "for a no existing publication" do     
      it "should return an error message" do
        get :show, :pubid => 9999, api_key: @api_key

        expect(json["error"]).to_not be nil
      end  
    end

    context "with author inc department" do
      it "should return a publication" do
        person = create(:person)
        department = create(:department)
        publication = create(:publication, pubid: 101)
        p2p = create(:people2publication, person: person, publication: publication)
        d2p2p = create(:departments2people2publication, people2publication: p2p, department: department)

        get :show, pubid: 101, api_key: @api_key

        expect(json['publication']).to_not be nil
        expect(json['publication']['authors']).to_not be nil
        expect(json['publication']['authors'][0]['id']).to eq person.id
        expect(json['publication']['authors'][0]['departments']).to_not be nil
        expect(json['publication']['authors'][0]['departments'][0]['id']).to eq department.id
      end

      it "should return a publication with an author list with presentation string on the form 'first_name last_name, year_of_birth (affiliation 1, affiliation 2)'" do
        person = create(:person, first_name: "Test", last_name: "Person", year_of_birth: 1980, affiliated: true)
        publication = create(:publication, pubid: 101)

        department1 = create(:department, name_sv: "department 1")
        department2 = create(:department, name_sv: "department 2")
        department3 = create(:department, name_sv: "department 3")

        people2publication = create(:people2publication, publication: publication, person: person)

        departments2people2publication1 = create(:departments2people2publication, people2publication: people2publication, department: department1)
        departments2people2publication2 = create(:departments2people2publication, people2publication: people2publication, department: department2)
        departments2people2publication3 = create(:departments2people2publication, people2publication: people2publication, department: department3)

        get :show, pubid: 101, api_key: @api_key

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
      end
      
      context "publication type suggestion" do
        it "should return a suggested publication type (pubmed)" do
          get :fetch_import_data, datasource: 'pubmed', sourceid: '25505574', api_key: @api_key
          expect(json['publication']).to_not be nil
          expect(json['error']).to be nil

          post :create, publication: json['publication'], api_key: @api_key
          expect(json['error']).to be_nil

          get :show, pubid: json['publication']['id'], api_key: @api_key
          expect(json['publication']['publication_type_suggestion']).to eq("journal-articles")
        end

        it "should return a suggested publication type (scopus)" do
          get :fetch_import_data, datasource: 'scopus', sourceid: '10.1109/IJCNN.2008.4634188', api_key: @api_key
          expect(json['publication']).to_not be nil
          expect(json['error']).to be nil

          post :create, publication: json['publication'], api_key: @api_key
          expect(json['error']).to be_nil

          get :show, pubid: json['publication']['id'], api_key: @api_key
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

          get :show, pubid: json['publication']['id'], api_key: @api_key
          expect(json['publication']['authors_from_import']).to be_a(Array)
          expect(json['publication']['authors_from_import'][0]).to be_a(Hash)
          expect(json['publication']['authors_from_import'][0]['last_name']).to eq("Brath")
          expect(json['publication']['authors_from_import'][0]['first_name']).to eq("Ulrika")
          expect(json['publication']['authors_from_import'][0]['affiliation']).to match(/Chemistry and Molecular/)
          expect(json['publication']['authors_from_import'][0]['full_author_string']).to match(/Chemistry and Molecular/)
        end

        it "should return list of authors as objects from imported post (scopus)" do
          get :fetch_import_data, datasource: 'scopus', sourceid: '10.1109/IJCNN.2008.4634188', api_key: @api_key
          expect(json['publication']).to_not be nil
          expect(json['error']).to be nil

          post :create, publication: json['publication'], api_key: @api_key
          expect(json['error']).to be_nil

          get :show, pubid: json['publication']['id'], api_key: @api_key
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

          get :show, pubid: json['publication']['id'], api_key: @api_key
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

          get :show, pubid: json['publication']['id'], api_key: @api_key
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
          pub = create(:publication, pubid: 45687)

          put :update, pubid: 45687, publication: {title: "New test title"}, api_key: @api_key 

          expect(json["publication"]["title"]).to eq "New test title"
          expect(json["publication"]).to_not be nil
          expect(json["publication"]).to be_an(Hash)
        end
      end
      context "with invalid parameters" do
        it "should return an error message" do
          create(:publication, pubid: 2001)

          put :update, pubid: 2001, publication: {publication_type: 'non-existing-type'}, api_key: @api_key

          expect(json["error"]).to_not be nil
        end
      end

    end
    context "for a non existing publication" do
      it "should return an error message" do
        create(:publication, pubid: 2001)

        put :update, pubid: 9999, publication: {title: "New test title"}, api_key: @api_key

        expect(json["error"]).to_not be nil
      end
    end

    context "with person inc department" do
      it "should return a publication" do
        publication = create(:publication)
        person = create(:person)
        department = create(:department)

        put :update, pubid: publication.pubid, publication: {authors: [{id: person.id, departments: [department.as_json]}]}, api_key: @api_key
        publication_new = Publication.where(pubid: publication.pubid).where(is_deleted: false).first

        expect(json['error']).to be nil
        expect(json['publication']['authors'][0]['id']).to eq person.id
        expect(json['publication']['authors'][0]['departments'][0]['id']).to eq department.id
        expect(publication_new.people2publications.size).to eq 1
        expect(publication_new.people2publications.first.departments2people2publications.count).to eq 1
      end

      it "should return a publication with an author list with presentation string on the form 'first_name last_name, year_of_birth (affiliation 1, affiliation 2)'" do
        person = create(:person, first_name: "Test", last_name: "Person", year_of_birth: 1980, affiliated: true)
        publication = create(:publication, pubid: 45687)

        department1 = create(:department, name_sv: "department 1")
        department2 = create(:department, name_sv: "department 2")
        department3 = create(:department, name_sv: "department 3")

        people2publication = create(:people2publication, publication: publication, person: person)

        departments2people2publication1 = create(:departments2people2publication, people2publication: people2publication, department: department1)
        departments2people2publication2 = create(:departments2people2publication, people2publication: people2publication, department: department2)
        departments2people2publication3 = create(:departments2people2publication, people2publication: people2publication, department: department3)

        put :update, pubid: 45687, publication: {title: "New test title", authors: [{id: person.id, departments: [department1.as_json, department2.as_json, department3.as_json]}]}, api_key: @api_key

        expect(json["publication"]["authors"]).to_not be nil
        expect(json["publication"]["authors"][0]["presentation_string"]).to eq "Test Person, 1980 (department 1, department 2)"
      end

      it "should set the person as affiliated" do
        publication = create(:publication)
        person = create(:person)
        department = create(:department)

        put :update, pubid: publication.pubid, publication: {authors: [{id: person.id, departments: [department.as_json]}]}, api_key: @api_key
        expect(Person.find_by_id(person.id).affiliated).to eq true    
      end    
    end

    context "With a list of categories" do
      it "should return a publication" do
        publication = create(:publication, pubid: 2001)

        put :update, pubid: 2001, publication: {category_hsv_local: [1,101]}, api_key: @api_key

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
          pub = create(:draft_publication, pubid: 45687)

          put :publish, pubid: 45687, publication: {title: "New test title"}, api_key: @api_key

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

        put :publish, pubid: publication.pubid, publication: {authors: [{id: person.id, departments: [department.as_json]}]}, api_key: @api_key
        publication_new = Publication.where(pubid: publication.pubid).where(is_deleted: false).first

        expect(json['error']).to be nil
        expect(json['publication']['authors'][0]['id']).to eq person.id
        expect(json['publication']['authors'][0]['departments'][0]['id']).to eq department.id
        expect(publication_new.people2publications.size).to eq 1
        expect(publication_new.people2publications.first.departments2people2publications.count).to eq 1
      end

      it "should return a publication with an author list with presentation string on the form 'first_name last_name, year_of_birth (affiliation 1, affiliation 2)'" do
        person = create(:person, first_name: "Test", last_name: "Person", year_of_birth: 1980, affiliated: true)
        publication = create(:publication, pubid: 45687)

        department1 = create(:department, name_sv: "department 1")
        department2 = create(:department, name_sv: "department 2")
        department3 = create(:department, name_sv: "department 3")

        people2publication = create(:people2publication, publication: publication, person: person)

        departments2people2publication1 = create(:departments2people2publication, people2publication: people2publication, department: department1)
        departments2people2publication2 = create(:departments2people2publication, people2publication: people2publication, department: department2)
        departments2people2publication3 = create(:departments2people2publication, people2publication: people2publication, department: department3)

        put :publish, pubid: 45687, publication: {title: "New test title", authors: [{id: person.id, departments: [department1.as_json, department2.as_json, department3.as_json]}]}, api_key: @api_key 

        expect(json["publication"]["authors"]).to_not be nil
        expect(json["publication"]["authors"][0]["presentation_string"]).to eq "Test Person, 1980 (department 1, department 2)"
      end
    end

    context "for an existing no deleted and published publication" do
      context "with valid parameters" do
        it "should return an error message" do
          pub = create(:publication, pubid: 45687)

          put :publish, pubid: 45687, publication: {title: "New test title"}, api_key: @api_key 

          expect(json["error"]).to be nil
          expect(json["publication"]).to_not be nil
        end
      end
    end
  end

  describe "bibl_review" do 
    context "with no admin rights" do
      it "should return an error message" do
        pub = create(:publication, pubid: 45687)
        
        get :bibl_review, pubid: 45687, api_key: @api_key

        expect(json["error"]).to_not be nil

      end
    end

    context "with invalid pubid and admin rights" do
      it "should return an error message" do
        get :bibl_review, pubid: 9999999, api_key: @api_admin_key

        expect(json["error"]).to_not be nil
      end
    end

    context "for a draft publication and admin rights" do
      it "should return an error message" do
        create(:draft_publication, pubid: 45687)

        get :bibl_review, pubid: 45687, api_key: @api_admin_key

        expect(json["error"]).to_not be nil
      end
    end


    context "for a valid pubid, valid publication state and admin rights" do
      it "should return a success message" do
        p = create(:publication, pubid: 45687)
        get :bibl_review, pubid: 45687, api_key: @api_admin_key

        expect(json["error"]).to be nil
        expect(json["publication"]).to_not be nil
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
        create(:draft_publication, pubid: 2001)

        delete :destroy, pubid: 2001, api_key: @api_key

        expect(response.status).to eq(200)
        expect(json).to be_kind_of(Hash)
        expect(json.empty?).to eq true

      end
    end

    context "for a published publication" do
      it "should return error msg for standard user" do
        create(:publication, pubid: 2001)

        delete :destroy, pubid: 2001, api_key: @api_key

        expect(response.status).to eq(403)
        expect(json['error']).to_not be nil
      end

      it "should not return error for admin" do
        create(:publication, pubid: 2001)

        delete :destroy, pubid: 2001, api_key: @api_admin_key

        expect(response.status).to eq(200)
        expect(json['error']).to be nil
      end
    end

    context "for a non existing publication" do
      it "should return an error message" do
        delete :destroy, pubid: 9999, api_key: @api_key

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
        department2people2publication = create(:departments2people2publication, people2publication: people2publication, department: department)

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
        #department2people2publication = create(:departments2people2publication, people2publication: people2publication, department: department)

        controller = V1::PublicationsController.new
        publications = controller.send('publications_for_review_by_actor', {person_id: person.id})

        expect(publications.count).to eq 0
      end
    end
  end
=end
end

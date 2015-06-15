require 'rails_helper'

RSpec.describe V1::PublicationsController, type: :controller do

  describe "index" do
    context "when requiring publications" do
      it "should return a list of objects" do
        create_list(:publication, 10)

        get :index 

        expect(json["publications"]).to_not be nil
        expect(json["publications"]).to be_an(Array)
      end
    end

    context "when requiring drafts" do

      it "should return a list of objects" do
        get :index, :drafts => 'true' 
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

          get :index, xkonto: 'xtest', is_actor: 'true'

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

          get :index, xkonto: 'xtest', is_actor: 'true', for_review: 'true'

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
          put :publish, pubid: 101, publication: {authors:[{id: person.id, departments: [{id: department.id}]}], abstract: 'something else', title: 'new title'}

          get :index, xkonto: 'xtest', is_actor: 'true', for_review: 'true'

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
          put :publish, pubid: 101, publication: {authors:[{id: person.id, departments: [{id: department.id}]}], abstract: 'something else', title: 'new title', content_type: 'vet'}

          get :index, xkonto: 'xtest', is_actor: 'true', for_review: 'true'

          expect(json['publications'].count).to eq 1

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
          put :publish, pubid: 101, publication: {authors:[{id: person.id, departments: [{id: department.id}]}], abstract: 'something else', title: 'new title', content_type: 'books'}

          get :index, xkonto: 'xtest', is_actor: 'true', for_review: 'true'

          expect(json['publications'].count).to eq 1

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

          put :publish, pubid: 101, publication: {authors:[{id: person.id, departments: [{id: department.id}]}], abstract: 'something else', title: 'new title', content_type: 'vet'}
          put :publish, pubid: 101, publication: {authors:[{id: person.id, departments: [{id: department.id}]}], abstract: 'something else', title: 'new title', content_type: 'pop'}
          
          get :index, xkonto: 'xtest', is_actor: 'true', for_review: 'true'

          expect(json['publications'].count).to eq 1

        end
      end

    end
  end

  describe "show" do
    context "for an existing publication" do
      it "should return an object" do
        create(:publication, pubid: 101)

        get :show, :pubid => 101

        expect(json["publication"]).to_not be nil
        expect(json["publication"]).to be_an(Hash)
      end
    end

    context "for a no existing publication" do     
      it "should return an error message" do
        get :show, :pubid => 9999

        expect(json["error"]).to_not be nil
      end  
    end

    context "with person inc department" do
      it "should return a publication" do
        person = create(:person)
        department = create(:department)
        publication = create(:publication, pubid: 101)
        p2p = create(:people2publication, person: person, publication: publication)
        d2p2p = create(:departments2people2publication, people2publication: p2p, department: department)

        get :show, pubid: 101

        expect(json['publication']).to_not be nil
        expect(json['publication']['authors']).to_not be nil
        expect(json['publication']['authors'][0]['id']).to eq person.id
        expect(json['publication']['authors'][0]['departments']).to_not be nil
        expect(json['publication']['authors'][0]['departments'][0]['id']).to eq department.id
      end
    end
  end

  describe "create" do 
    context "with datasource parameter" do 
      it "should return created publication" do 
        post :create, :datasource => 'none'
        expect(json["publication"]).to_not be nil
        expect(json["publication"]).to be_an(Hash)
      end
    end
    context "with no parameter" do
      it "should return an error message" do
        post :create
        expect(json["publication"]).to_not be nil
        expect(json["publication"]).to be_an(Hash)      
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

          put :update, pubid: 45687, publication: {title: "New test title"} 

          expect(json["publication"]["title"]).to eq "New test title"
          expect(json["publication"]).to_not be nil
          expect(json["publication"]).to be_an(Hash)
        end
      end
      context "with invalid parameters" do
        it "should return an error message" do
          create(:publication, pubid: 2001)

          put :update, pubid: 2001, publication: {publication_type: 'non-existing-type'}

          expect(json["error"]).to_not be nil
        end
      end

    end
    context "for a non existing publication" do
      it "should return an error message" do
        create(:publication, pubid: 2001)

        put :update, pubid: 9999, publication: {title: "New test title"} 

        expect(json["error"]).to_not be nil
      end
    end

    context "with person inc department" do
      it "should return a publication" do
        publication = create(:publication)
        person = create(:person)
        department = create(:department)

        put :update, pubid: publication.pubid, publication: {authors: [{id: person.id, departments: [department.as_json]}]}
        publication_new = Publication.where(pubid: publication.pubid).where(is_deleted: false).first

        expect(json['error']).to be nil
        expect(json['publication']['authors'][0]['id']).to eq person.id
        expect(json['publication']['authors'][0]['departments'][0]['id']).to eq department.id
        expect(publication_new.people2publications.size).to eq 1
        expect(publication_new.people2publications.first.departments2people2publications.count).to eq 1
      end

      it "should set the person as affiliated" do
        publication = create(:publication)
        person = create(:person)
        department = create(:department)

        put :update, pubid: publication.pubid, publication: {authors: [{id: person.id, departments: [department.as_json]}]}
        expect(Person.find_by_id(person.id).affiliated).to eq true    
      end    
    end

    context "With a list of categories" do
      it "should return a publication" do
        publication = create(:publication, pubid: 2001)

        put :update, pubid: 2001, publication: {category_hsv_local: [1,101]}

        expect(json["error"]).to be nil
        expect(json["publication"]["category_hsv_local"]).to eq [1, 101]
      end
    end
  end

  describe "publish" do
    context "for an existing no deleted and draft publication" do
      context "with valid parameters" do
        it "should return updated publication" do
          pub = create(:draft_publication, pubid: 45687)

          put :publish, pubid: 45687, publication: {title: "New test title"} 

          expect(json["publication"]).to_not be nil
          expect(json["publication"]).to be_an(Hash)
          expect(json["publication"]["title"]).to eq "New test title"
          expect(json["publication"]["published_at"]).to_not be nil
        end
      end
    end

    context "for an existing no deleted and published publication" do
      context "with valid parameters" do
        it "should return an error message" do
          pub = create(:publication, pubid: 45687)

          put :publish, pubid: 45687, publication: {title: "New test title"} 

          expect(json["error"]).to be nil
          expect(json["publication"]).to_not be nil
        end
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
        get :fetch_import_data, datasource: 'pubmed', sourceid: '25505574'

        expect(json['publication']).to_not be nil
        expect(json['errors']).to be nil
      end
    end
  end

  describe "destroy" do
    context "for a draft publication" do
      it "should return an empty hash" do
        create(:draft_publication, pubid: 2001)

        delete :destroy, pubid: 2001 

        expect(json).to be_kind_of(Hash)
        expect(json.empty?).to eq true

      end
    end

    context "for a published publication" do
      it "should return error msg" do
        create(:publication, pubid: 2001)

        delete :destroy, pubid: 2001

        expect(json['error']).to_not be nil
      end
    end

    context "for a non existing publication" do
      it "should return an error message" do
        delete :destroy, pubid: 9999

        expect(json["error"]).to_not be nil
      end
    end 
  end
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
end

require 'rails_helper'

RSpec.describe V1::PublicationsController, type: :controller do
  before :each do
    create(:publication_type, label: 'none')
  end
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
      before :each do 
        stub_request(:get, "http://publication-url.test.com/publications/drafts.json").
        with(:query => {:username => "api"}).
        to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/publication/drafts.json"), :headers => {})
      end

      it "should return a list of objects" do
        get :index, :drafts => 'true' 
        expect(json["publications"]).to_not be nil
        expect(json["publications"]).to be_an(Array)
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
    context "for an existing publication" do
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

          put :update, pubid: 2001, publication: {publication_type_id: 99999}

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
  end


  describe "destroy" do
    context "for an existing publication" do
      it "should return updated publication" do
        create(:publication, pubid: 2001)

        put :destroy, pubid: 2001 

        expect(json).to be_kind_of(Hash)
      end
    end
    context "for a non existing publication" do
      it "should return an error message" do
        put :destroy, pubid: 9999
        
        expect(json["error"]).to_not be nil
      end
    end 

  end
end

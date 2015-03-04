require 'rails_helper'



RSpec.describe PublicationsController, type: :controller do

  describe "index" do
    context "when requiring publications" do
      before :each do 
        stub_request(:get, "http://publication-url.test.com/publications.json").
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/responses/publications.json"), :headers => {})
      end
      it "should return a list of objects" do
        get :index 
        expect(json["publications"]).to_not be nil
        expect(json["publications"]).to be_an(Array)
      end
    end

    context "when requiring drafts" do
      before :each do 
        stub_request(:get, "http://publication-url.test.com/publications/drafts.json").
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/responses/drafts.json"), :headers => {})
      end
    
      it "should return a list of objects" do
        get :index, :drafts => 'true' 
        expect(json["publications"]).to_not be nil
        expect(json["publications"]).to be_an(Array)
      end
    end
  end


  describe "show" do
    context "for an existing pubid" do
      before :each do 
        stub_request(:get, "http://publication-url.test.com/publications/101.json").
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/responses/show_success.json"), :headers => {})
      end    
      it "should return an object" do
        get :show, :id => 101
        expect(json["publication"]).to_not be nil
        expect(json["publication"]).to be_an(Hash)
      end
    end

    context "for a no existing pubid" do
      before :each do 
        stub_request(:get, "http://publication-url.test.com/publications/9999.json").
          to_return(:status => 404, :body => File.new("#{Rails.root}/spec/support/responses/show_error.json"), :headers => {})
      end         
      it "should return an error message" do
        get :show, :id => 9999
        expect(json["errors"]).to_not be nil
      end  
    end
  end

  describe "create" do 
    context "with no required datasource" do 
      before :each do 
        stub_request(:post, "http://publication-url.test.com/publications.json").
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/responses/create_success.json"), :headers => {})
      end
      it "should return created publication" do 
        post :create, :datasource => 'none'
        expect(json["publication"]).to_not be nil
        expect(json["publication"]).to be_an(Hash)
      end
    end
  end


  describe "update" do
    context "for an existing pubid" do
      before :each do
        stub_request(:get, "http://publication-url.test.com/publications/2001.json").
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/responses/create_success.json"), :headers => {})

        stub_request(:put, "http://publication-url.test.com/publications/201.json").
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/responses/update_success.json"), :headers => {})
      end
      it "should return updated publication" do
        put :update, id: 2001, publication: {title: "New test title"} 
        expect(json["publication"]).to_not be nil
        expect(json["publication"]).to be_an(Hash)
      end
    end
  end

  describe "destroy" do
    context "for an existing pubid" do
      before :each do
        stub_request(:get, "http://publication-url.test.com/publications/2001.json").
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/responses/create_success.json"), :headers => {})

        stub_request(:delete, "http://publication-url.test.com/publications/201.json").
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/responses/delete_success.json"), :headers => {})
      end
      it "should return updated publication" do
        put :destroy, id: 2001 
        expect(json).to be_kind_of(Hash)
      end
    end
  end

end


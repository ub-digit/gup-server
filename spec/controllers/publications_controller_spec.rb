require 'rails_helper'



RSpec.describe PublicationsController, type: :controller do

  describe "index" do
    context "when requiring publications" do
      before :each do 
        stub_request(:get, "http://publication-url.test.com/publications.json").
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/publication/index.json"), :headers => {})
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
      before :each do 
        stub_request(:get, "http://publication-url.test.com/publications/101.json").
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/publication/show_success.json"), :headers => {})
      end    
      it "should return an object" do
        get :show, :pubid => 101
        expect(json["publication"]).to_not be nil
        expect(json["publication"]).to be_an(Hash)
      end
    end

    context "for a no existing publication" do
      before :each do 
        stub_request(:get, "http://publication-url.test.com/publications/9999.json").
          to_return(:status => 404, :body => File.new("#{Rails.root}/spec/support/publication/show_error_404.json"), :headers => {})
      end         
      it "should return an error message" do
        get :show, :pubid => 9999
        expect(json["error"]).to_not be nil
      end  
    end
  end

  describe "create" do 
    context "with required datasource is none" do 
      before :each do 
        stub_request(:post, "http://publication-url.test.com/publications.json").
          to_return(:status => 201, :body => File.new("#{Rails.root}/spec/support/publication/create_success.json"), :headers => {})
      end
      it "should return created publication" do 
        post :create, :datasource => 'none'
        expect(json["publication"]).to_not be nil
        expect(json["publication"]).to be_an(Hash)
      end
    end
    context "with a file parameter" do 
      before :each do 
       stub_request(:post, "http://publication-url.test.com/publications.json").
        to_return(:status => 201, :body => File.new("#{Rails.root}/spec/support/publication/create_success.json"), :headers => {})
      end
      it "should return the last created publication" do 
        post :create, :file => 'xyz'
        expect(json["publication"]).to_not be nil
        expect(json["publication"]).to be_an(Hash)
      end
    end
    context "with missing datasource" do
      before :each do
        stub_request(:post, "http://publication-url.test.com/publications.json").
          to_return(:status => 422, :body => File.new("#{Rails.root}/spec/support/publication/create_error_422.json"), :headers => {})
      end
      it "should return an error message" do
        post :create
        expect(json["error"]).to_not be nil
      end
    end
  end  

  describe "update" do
    context "for an existing publication" do
      context "with valid parameters" do
        before :each do
          stub_request(:get, "http://publication-url.test.com/publications/2001.json").
            to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/publication/create_success.json"), :headers => {})

          stub_request(:put, "http://publication-url.test.com/publications/2001.json").
            to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/publication/update_success.json"), :headers => {})
        end
        it "should return updated publication" do
          put :update, pubid: 2001, publication: {title: "New test title"} 
          expect(json["publication"]).to_not be nil
          expect(json["publication"]).to be_an(Hash)
        end
      end
      context "with invalid parameters" do
        before :each do
          stub_request(:get, "http://publication-url.test.com/publications/2001.json").
            to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/publication/create_success.json"), :headers => {})

          stub_request(:put, "http://publication-url.test.com/publications/2001.json").
            to_return(:status => 422, :body => File.new("#{Rails.root}/spec/support/publication/update_error_422.json"), :headers => {})
        end
        it "should return an error message" do
          put :update, pubid: 2001, publication: {publication_type: 99999} 
          expect(json["error"]).to_not be nil
        end
      end
    end
    context "for a non existing publication" do
      before :each do
        stub_request(:get, "http://publication-url.test.com/publications/9999.json").
          to_return(:status => 404, :body => File.new("#{Rails.root}/spec/support/publication/update_error_404.json"), :headers => {})
      end
      it "should return an error message" do
        put :update, pubid: 9999, publication: {title: "New test title"} 
        expect(json["error"]).to_not be nil
      end
    end 
  end


  describe "destroy" do
    context "for an existing publication" do
      before :each do
        stub_request(:get, "http://publication-url.test.com/publications/2001.json").
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/publication/create_success.json"), :headers => {})

        stub_request(:delete, "http://publication-url.test.com/publications/2001.json").
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/publication/delete_success.json"), :headers => {})
      end
      it "should return updated publication" do
        put :destroy, pubid: 2001 
        expect(json).to be_kind_of(Hash)
      end
    end
    context "for a non existing publication" do
      before :each do
        stub_request(:get, "http://publication-url.test.com/publications/9999.json").
          to_return(:status => 404, :body => File.new("#{Rails.root}/spec/support/publication/delete_error_404.json"), :headers => {})
      end
      it "should return an error message" do
        put :destroy, pubid: 9999
        expect(json["error"]).to_not be nil
      end
    end 

  end

end


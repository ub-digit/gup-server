require 'rails_helper'

RSpec.describe PeopleController, type: :controller do


  describe "index" do

    context "without any parameter" do
      before :each do
        stub_request(:get, "http://people-url.test.com/people.json").
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/person/index.json"), :headers => {})
      end
      it "should return a list of all people without parameters" do
        get :index 
        expect(json["people"]).to_not be nil
        expect(json["people"]).to be_an(Array)
      end
    end
    context "with parameter search_terms=xaaaaa" do
      before :each do
        stub_request(:get, "http://people-url.test.com/people.json").
          with(query: {"search_term" => "xaaaaa"}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/person/index_search_term.json"), :headers => {})
      end
      it "should return a list of people" do
        get :index, search_term: 'xaaaaa'
        expect(json["people"]).to_not be nil
        expect(json["people"]).to be_an(Array)
      end
    end
  end

  describe "show" do
    before :each do
      stub_request(:get, "http://people-url.test.com/people/1.json").
        to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/person/show_success.json"), :headers => {})
      stub_request(:get, "http://people-url.test.com/people/999.json").
        to_return(:status => 404, :body => File.new("#{Rails.root}/spec/support/person/show_error_404.json"), :headers => {})
    end
    it "should return a person for an existing id" do
      get :show, id: 1
      expect(json["person"]).to_not be nil
      expect(json["person"]).to be_an(Hash)
    end
    it "should return an error message for a no existing id" do
      get :show, id: 999
      expect(json["error"]).to_not be nil
    end
  end


  describe "create" do 
    context "with valid parameters" do
      before :each do 
        stub_request(:post, "http://people-url.test.com/people.json").
          to_return(:status => 201, :body => File.new("#{Rails.root}/spec/support/person/create_success.json"), :headers => {})
      end
      it "should return created person" do 
        post :create, person: {first_name: "Nisse", last_name: "Hult", year_of_birth: "1917"}
        expect(json["person"]).to_not be nil
        expect(json["person"]).to be_an(Hash)
      end
    end
    context "with invalid parameters" do
      before :each do
        stub_request(:post, "http://people-url.test.com/people.json").
          to_return(:status => 422, :body => File.new("#{Rails.root}/spec/support/person/create_error_422.json"), :headers => {})
      end
      it "should return an error message" do
        put :create, person: {first_name: "Nisse", last_name: "", year_of_birth: "1918"}
        expect(json["error"]).to_not be nil
      end
    end  
  end

  describe "update" do
    context "for an existing person" do
      context "with valid parameters" do
        before :each do
          stub_request(:get, "http://people-url.test.com/people/10.json").
            to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/person/create_success.json"), :headers => {})

          stub_request(:put, "http://people-url.test.com/people/10.json").
            to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/person/update_success.json"), :headers => {})
        end
        it "should return updated publication" do
          put :update, id: 10, person: {first_name: "Nisse", last_name: "Bult", year_of_birth: "1918"}
          expect(json["person"]).to_not be nil
          expect(json["person"]).to be_an(Hash)
        end
      end
      context "with invalid parameters" do
        before :each do
          stub_request(:get, "http://people-url.test.com/people/10.json").
            to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/person/create_success.json"), :headers => {})

          stub_request(:put, "http://people-url.test.com/people/10.json").
            to_return(:status => 422, :body => File.new("#{Rails.root}/spec/support/person/update_error_422.json"), :headers => {})
        end
        it "should return an error message" do
          put :update, id: 10, person: {first_name: "Nisse", last_name: "", year_of_birth: "1918"}
          expect(json["error"]).to_not be nil
        end
      end
    end
    context "for a non existing person" do
      before :each do
        stub_request(:get, "http://people-url.test.com/people/9999.json").
          to_return(:status => 404, :body => File.new("#{Rails.root}/spec/support/person/update_error_404.json"), :headers => {})
      end
      it "should return an error message" do
        put :update, id: 9999, person: {first_name: "Nisse", last_name: "Bult", year_of_birth: "1918"}
        expect(json["error"]).to_not be nil
      end
    end 
  end

end

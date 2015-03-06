require 'rails_helper'



RSpec.describe PublicationTypesController, type: :controller do

  describe "index" do
    before :each do
      stub_request(:get, "http://publication-url.test.com/publication_types.json").
        to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/publication_type/index.json"), :headers => {})
    end
    it "should return a list of publication types" do
      get :index 
      expect(json["publication_types"]).to_not be nil
      expect(json["publication_types"]).to be_an(Array)
    end
  end


  describe "show" do
    before :each do
      stub_request(:get, "http://publication-url.test.com/publication_types/1.json").
        to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/publication_type/show_success.json"), :headers => {})
      stub_request(:get, "http://publication-url.test.com/publication_types/999.json").
        to_return(:status => 404, :body => File.new("#{Rails.root}/spec/support/publication_type/show_error_404.json"), :headers => {})
    end
    it "should return a publication type for an existing id" do
      get :show, id: 1
      expect(json["publication_type"]).to_not be nil
      expect(json["publication_type"]).to be_an(Hash)
    end
    it "should return an error message for a no existing id" do
      get :show, id: 999
      expect(json["error"]).to_not be nil
    end

  end

end


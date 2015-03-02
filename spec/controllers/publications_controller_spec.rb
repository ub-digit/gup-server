require 'rails_helper'



RSpec.describe PublicationsController, type: :controller do
  before :each do 
    stub_request(:get, "http://publication-url.test.com/publications.json").
    with(:headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
    to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/publications.json"), :headers => {})
  end
  describe "index" do
    it "should return a list of objects" do
      get :index
      expect(json["publications"]).to_not be nil
      expect(json["publications"]).to be_an(Array)
    end
  end
end

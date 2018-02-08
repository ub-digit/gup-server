require 'rails_helper'

RSpec.describe V1::JournalsController, type: :controller do
  before :each do
    stub_request(:get, APP_CONFIG['journal_index_url']+"select?fl=journal_identifier_mapping&q=Digital&wt=ruby").
      to_return(:status => 200, :body => File.open("#{Rails.root}/spec/support/solr/digital-test.data"), :headers => {})
  end

  describe "search" do
    it "should return a list of journals matching query" do
      get :search, search_term: "Digital", api_key: @api_key
      expect(json['journals']).to_not be_empty
      expect(json['journals'].count).to eq(10)
      expect(json['journals'][0]['issn']).to eq('1617-6901')
    end
  end
end

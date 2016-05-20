require 'rails_helper'

RSpec.describe V1::ImportsController, type: :controller do

  describe "show" do
    context "for existing pubmed" do
      before :each do
        stub_request(:get, "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=25505574&retmode=xml").
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/pubmed-25505574.xml"), :headers => {})
       end

      it "should return a publication object" do
        post :create, publication: {datasource: 'pubmed', sourceid: '25505574'}, api_key: @api_key
        expect(json['publication']).to_not be nil
        expect(json['error']).to be nil
      end
    end
  end

end

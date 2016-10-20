require 'rails_helper'

RSpec.describe V1::ImportsController, type: :controller do

  describe "create" do
    context "for existing datasource and sourceid" do
      before :each do
        stub_request(:get, "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=25505574&retmode=xml").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=> 'eutils.ncbi.nlm.nih.gov'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/pubmed-25505574.xml"), :headers => {})
       end

      it "should return a publication object" do
        post :create, publication: {datasource: 'pubmed', sourceid: '25505574'}, api_key: @api_key
        expect(json['publication']).to_not be nil
        expect(json['error']).to be nil
      end
    end

    context "for non existing datasource" do
      it "should return an error message" do
        post :create, publication: {datasource: 'notexist', sourceid: '25505574'}, api_key: @api_key

        expect(json['publication']).to be nil
        expect(json['error']).to_not be nil
        expect(response.status).to eq 404
      end
    end

    context "for a non existing source id" do
      it "should return an error message" do
        stub_request(:get, "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=255055741354975&retmode=xml").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=> 'eutils.ncbi.nlm.nih.gov'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/pubmed-255055741354975.xml"), :headers => {})

        post :create, publication: {datasource: 'pubmed', sourceid: "255055741354975"}, api_key: @api_key

        expect(json['publication']).to be nil
        expect(json['error']).to_not be nil
        expect(response.status).to eq 422
      end
    end
  end
end

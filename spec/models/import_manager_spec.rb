require 'rails_helper'

RSpec.describe ImportManager, type: :model do

  before :each do
    stub_request(:get, "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=25505574&retmode=xml").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=> 'eutils.ncbi.nlm.nih.gov'}).
      to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/pubmed-25505574.xml"), :headers => {})
  end

  describe "find_adapter" do
    context "for a random existing adapter" do
      it "should return an adapter object" do
        datasources = ImportManager::ADAPTERS
        index = rand(datasources.size)
        datasource = datasources.keys[index]
        adapter = ImportManager.find_adapter(datasource: datasource)

        expect(adapter.name).to eq datasources[datasource].name
      end
    end
    context "for all existing adapters" do
      it "should return an adapter object" do
        expect(ImportManager.find_adapter(datasource: 'pubmed').name).to eq 'PubmedAdapter'
        expect(ImportManager.find_adapter(datasource: 'libris').name).to eq 'LibrisAdapter'
        expect(ImportManager.find_adapter(datasource: 'scopus').name).to eq 'ScopusAdapter'
        expect(ImportManager.find_adapter(datasource: 'scigloo').name).to eq 'SciglooAdapter'
        expect(ImportManager.find_adapter(datasource: 'gupea').name).to eq 'GupeaAdapter'
        expect(ImportManager.find_adapter(datasource: 'endnote').name).to eq 'EndnoteAdapter'
      end
    end

    context "for a non existing adapter" do
      it "should raise a StandardError" do

        expect{ImportManager.find_adapter(datasource: 'notexist')}.to raise_error StandardError
      end
    end
  end

  describe "find" do
    context "for an existing datasource and sourceid" do
      it "should return an adapter object responding to .json_data" do
        adapter_object = ImportManager.find(datasource: 'pubmed', sourceid: '25505574')

        expect(adapter_object).to respond_to :json_data
      end
    end
  end

  describe "datasource_valid" do
    context "for a valid datasource" do
      it "should return true" do
        datasource = ImportManager::ADAPTERS.keys.first

        result = ImportManager.datasource_valid?(datasource: datasource)

        expect(result).to be true
      end
    end
    context "for an invalid datasource" do
      it "should return false" do
        datasource = 'notexist'

        result = ImportManager.datasource_valid?(datasource: datasource)

        expect(result).to be false
      end
    end
  end
end

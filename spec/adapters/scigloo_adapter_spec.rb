require 'rails_helper'

RSpec.describe SciglooAdapter, :type => :model do
  before :each do
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  after :each do
    WebMock.allow_net_connect!
  end
  describe "find_by_id" do
    context "with an existing id" do
      before :each do
        stub_request(:get, "http://solr.lib.chalmers.se:8080/solr/scigloo/select?q=*%3A*&fq=pubid%3A170399&wt=xml&indent=true").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'solr.lib.chalmers.se:8080'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/scigloo-170399.xml"), :headers => {})

        stub_request(:get, "http://solr.lib.chalmers.se:8080/solr/scigloo/select?q=*%3A*&fq=pubid%3A170398&wt=xml&indent=true").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'solr.lib.chalmers.se:8080'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/scigloo-170398.xml"), :headers => {})
      end
      it "should return a valid object" do
        scigloo = SciglooAdapter.find_by_id "170399"
        expect(scigloo.errors.messages.empty?).to be_truthy
      end
      it "should return a valid object with parameters" do
        scigloo = SciglooAdapter.find_by_id "170399"
        expect(scigloo.title.present?).to be_truthy
        expect(scigloo.pubyear.present?).to be_truthy
        # ...
      end
      it "should provide a hash of jsonable data" do
        scigloo = SciglooAdapter.find_by_id "170399"
        expect(scigloo.json_data).to be_kind_of(Hash)
        expect(scigloo.json_data[:title]).to be_present
      end
      it "should be able to read data in non-UTF-8 format" do
        scigloo = SciglooAdapter.find_by_id "170398"
        expect(scigloo.json_data).to be_kind_of(Hash)
        expect(scigloo.json_data[:title]).to be_present
      end
      it "should provide a list of authors" do
        scigloo = SciglooAdapter.find_by_id "170399"
        xml = Nokogiri::XML(scigloo.xml)
        xml.remove_namespaces!
        expect(SciglooAdapter.authors(xml)).to be_kind_of(Array)
        expect(SciglooAdapter.authors(xml).first[:first_name]).to be_present
      end
      # This is not yet implemented
      it "should not provide a publication type suggestion" do
        scigloo = SciglooAdapter.find_by_id "170399"
        xml = Nokogiri::XML(scigloo.xml)
        xml.remove_namespaces!
        expect(SciglooAdapter.publication_type_suggestion(xml)).to be nil
      end
    end
    context "with a no existing id" do
      before :each do
        stub_request(:get, "http://solr.lib.chalmers.se:8080/solr/scigloo/select?q=*%3A*&fq=pubid%3A170399999999&wt=xml&indent=true").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'solr.lib.chalmers.se:8080'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/scigloo-170399999999.xml"), :headers => {})
      end
      it "should return a invalid object" do
        scigloo = SciglooAdapter.find_by_id "170399999999"
        expect(scigloo.errors.messages.empty?).to be_falsey
      end
    end
    context "with no id" do
      before :each do
        stub_request(:get, "http://solr.lib.chalmers.se:8080/solr/scigloo/select?q=*%3A*&fq=pubid%3A&wt=xml&indent=true").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'solr.lib.chalmers.se:8080'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/scigloo-nil.xml"), :headers => {})
      end
      it "should return a invalid object" do
        scigloo = SciglooAdapter.find_by_id ""
        expect(scigloo.errors.messages.empty?).to be_falsey
      end
    end
  end
end



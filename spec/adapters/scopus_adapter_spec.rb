
require 'rails_helper'

RSpec.describe ScopusAdapter, :type => :model do
  before :each do
    WebMock.disable_net_connect!(allow_localhost: true)
  end
  after :each do
    WebMock.allow_net_connect!
  end
  describe "find_by_id" do
    context "with an existing id" do
      before :each do
        stub_request(:get, "http://api.elsevier.com/content/search/index:SCOPUS?count=1&query=DOI(10.1109/IJCNN.2008.4634188)&start=0&view=COMPLETE").
          with(:headers => {'Accept'=>'application/atom+xml', 'Accept-Encoding'=>'gzip, deflate', 'X-Els-Apikey'=>'1122334455', 'X-Els-Resourceversion'=>'XOCS', 'Host'=>'api.elsevier.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/scopus-10.1109%2fIJCNN.2008.4634188.xml"), :headers => {})

        stub_request(:get, "http://api.elsevier.com/content/search/index:SCOPUS?count=1&query=DOI(10.1109/IJCNN.2008.4634189)&start=0&view=COMPLETE").
          with(:headers => {'Accept'=>'application/atom+xml', 'Accept-Encoding'=>'gzip, deflate', 'X-Els-Apikey'=>'1122334455', 'X-Els-Resourceversion'=>'XOCS', 'Host'=>'api.elsevier.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/scopus-10.1109%2fIJCNN.2008.4634189.xml"), :headers => {})
      end
      it "should return a valid object" do
        scopus = ScopusAdapter.find_by_id "10.1109/IJCNN.2008.4634188"
        expect(scopus.errors.messages.empty?).to be_truthy
      end
      it "should return a valid object with parameters" do
        scopus = ScopusAdapter.find_by_id "10.1109/IJCNN.2008.4634188"
        expect(scopus.title.present?).to be_truthy
        expect(scopus.pubyear.present?).to be_truthy
        # ...
      end
      it "should provide a hash of jsonable data" do
        scopus = ScopusAdapter.find_by_id "10.1109/IJCNN.2008.4634188"
        expect(scopus.json_data).to be_kind_of(Hash)
        expect(scopus.json_data[:title]).to be_present
      end
      it "should provide a hash of jsonable data with keyword" do
        scopus = ScopusAdapter.find_by_id "10.1109/IJCNN.2008.4634189"
        expect(scopus.json_data).to be_kind_of(Hash)
        expect(scopus.json_data[:keywords]).to be_present
      end
      it "should be able to read data in non-UTF-8 format" do
        scopus = ScopusAdapter.find_by_id "10.1109/IJCNN.2008.4634189"
        expect(scopus.json_data).to be_kind_of(Hash)
        expect(scopus.json_data[:title]).to be_present
      end
      it "should provide a list of authors" do
        scopus = ScopusAdapter.find_by_id "10.1109/IJCNN.2008.4634188"
        xml = Nokogiri::XML(scopus.xml)
        xml.remove_namespaces!
        expect(ScopusAdapter.authors(xml)).to be_kind_of(Array)
        expect(ScopusAdapter.authors(xml).first[:first_name]).to be_present
      end
      it "should provide a publication type suggestion" do
        scopus = ScopusAdapter.find_by_id "10.1109/IJCNN.2008.4634188"
        xml = Nokogiri::XML(scopus.xml)
        xml.remove_namespaces!
        expect(ScopusAdapter.publication_type_suggestion(xml)).to eq("conference_paper")
      end
    end
    context "with a no existing id" do
      before :each do
        stub_request(:get, "http://api.elsevier.com/content/search/index:SCOPUS?count=1&query=DOI(123456789/987654321)&start=0&view=COMPLETE").
          with(:headers => {'Accept'=>'application/atom+xml', 'Accept-Encoding'=>'gzip, deflate', 'X-Els-Apikey'=>'1122334455', 'X-Els-Resourceversion'=>'XOCS', 'Host'=>'api.elsevier.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/scopus-123456789%2f987654321.xml"), :headers => {})
      end
      it "should return a invalid object" do
        scopus = ScopusAdapter.find_by_id "123456789/987654321"
        expect(scopus.errors.messages.empty?).to be_falsey
      end
    end
    context "with no id" do
      before :each do
        stub_request(:get, "http://api.elsevier.com/content/search/index:SCOPUS?count=1&query=DOI()&start=0&view=COMPLETE").
          with(:headers => {'Accept'=>'application/atom+xml', 'Accept-Encoding'=>'gzip, deflate', 'X-Els-Apikey'=>'1122334455', 'X-Els-Resourceversion'=>'XOCS', 'Host'=>'api.elsevier.com'}).
          to_return(:status => 400, :body => "", :headers => {})
      end
      it "should return nil" do
        scopus = ScopusAdapter.find_by_id ""
        expect(scopus.nil?).to be_truthy
      end
    end
  end
end



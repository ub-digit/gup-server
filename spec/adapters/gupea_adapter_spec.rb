require 'rails_helper'

RSpec.describe GupeaAdapter, :type => :model do
  before :each do
    WebMock.disable_net_connect!(allow_localhost: true)
  end
  after :each do
    WebMock.allow_net_connect!
  end
  describe "find_by_id" do
    context "with an existing id" do
      before :each do
        stub_request(:get, "http://gupea.ub.gu.se/dspace-oai/request?identifier=oai:gupea.ub.gu.se:2077/12345&metadataPrefix=scigloo&verb=GetRecord").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'gupea.ub.gu.se'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/gupea-12345.xml"), :headers => {})

        stub_request(:get, "http://gupea.ub.gu.se/dspace-oai/request?identifier=oai:gupea.ub.gu.se:2077/12346&metadataPrefix=scigloo&verb=GetRecord").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'gupea.ub.gu.se'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/gupea-12346.xml"), :headers => {})
      end
      it "should return a valid object" do
        gupea = GupeaAdapter.find_by_id "12345"

        expect(gupea.errors.messages.empty?).to be_truthy
      end
      it "should return a valid object with parameters" do
        gupea = GupeaAdapter.find_by_id "12345"
        expect(gupea.title.present?).to be_truthy
        expect(gupea.pubyear.present?).to be_truthy
        # ...
      end
      it "should provide a hash of jsonable data" do
        gupea = GupeaAdapter.find_by_id "12345"
        expect(gupea.json_data).to be_kind_of(Hash)
        expect(gupea.json_data[:title]).to be_present
      end
      it "should provide a hash of jsonable data with abstract" do
        gupea = GupeaAdapter.find_by_id "12346"
        expect(gupea.json_data).to be_kind_of(Hash)
        expect(gupea.json_data[:abstract]).to be_present
      end
      it "should provide a hash of jsonable data with keyword" do
        gupea = GupeaAdapter.find_by_id "12346"
        expect(gupea.json_data).to be_kind_of(Hash)
        expect(gupea.json_data[:keywords]).to be_present
      end
      it "should provide a hash of jsonable data with isbn" do
        gupea = GupeaAdapter.find_by_id "12346"
        expect(gupea.json_data).to be_kind_of(Hash)
        expect(gupea.json_data[:isbn]).to be_present
      end
      it "should provide a list of authors" do
        gupea = GupeaAdapter.find_by_id "12345"
        xml = Nokogiri::XML(gupea.xml)
        xml.remove_namespaces!
        expect(GupeaAdapter.authors(xml)).to be_kind_of(Array)
        expect(GupeaAdapter.authors(xml).first[:first_name]).to be_present
      end
      it "should provide a publication type suggestion" do
        gupea = GupeaAdapter.find_by_id "12345"
        xml = Nokogiri::XML(gupea.xml)
        xml.remove_namespaces!
        expect(GupeaAdapter.publication_type_suggestion(xml)).to eq("publication_doctoral-thesis")
      end
    end
    context "with a no existing id" do
      before :each do
        stub_request(:get, "http://gupea.ub.gu.se/dspace-oai/request?identifier=oai:gupea.ub.gu.se:2077/123459999999&metadataPrefix=scigloo&verb=GetRecord").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'gupea.ub.gu.se'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/gupea-123459999999.xml"), :headers => {})
      end
      it "should return a invalid object" do
        gupea = GupeaAdapter.find_by_id "123459999999"
        expect(gupea.errors.messages.empty?).to be_falsey
      end
    end
    context "with no id" do
      before :each do
        stub_request(:get, "http://gupea.ub.gu.se/dspace-oai/request?identifier=oai:gupea.ub.gu.se:2077/&metadataPrefix=scigloo&verb=GetRecord").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'gupea.ub.gu.se'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/gupea-nil.xml"), :headers => {})
      end
      it "should return a invalid object" do
        gupea = GupeaAdapter.find_by_id ""
        expect(gupea.errors.messages.empty?).to be_falsey
      end
    end
  end
end



require 'rails_helper'

RSpec.describe GupeaAdapter, :type => :model do
  before :each do
    WebMock.disable_net_connect!
  end
  after :each do
    WebMock.allow_net_connect!
  end
  describe "find_by_id" do
    context "with an existing id" do
      before :each do
        stub_request(:get, "http://gupea.ub.gu.se/dspace-oai/request?identifier=oai:gupea.ub.gu.se:2077/12345&metadataPrefix=scigloo&verb=GetRecord").
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/gupea-12345.xml"), :headers => {})
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
    end
    context "with a no existing id" do
      before :each do
        stub_request(:get, "http://gupea.ub.gu.se/dspace-oai/request?identifier=oai:gupea.ub.gu.se:2077/123459999999&metadataPrefix=scigloo&verb=GetRecord").
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
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
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/gupea-nil.xml"), :headers => {})
      end
      it "should return a invalid object" do
        gupea = GupeaAdapter.find_by_id ""
        expect(gupea.errors.messages.empty?).to be_falsey
      end
    end
    context "with an invalid id" do
      it "should return nil" do
        gupea = GupeaAdapter.find_by_id "123 4321"
        expect(gupea.nil?).to be_truthy
      end
    end
  end
end



require 'rails_helper'

RSpec.describe Scigloo, :type => :model do
  before :each do
    WebMock.disable_net_connect!
  end

  after :each do
    WebMock.allow_net_connect!
  end
  describe "find_by_id" do
    context "with an existing id" do
      before :each do
        stub_request(:get, "http://solr.lib.chalmers.se:8080/solr/scigloo/select?q=*%3A*&fq=pubid%3A170399&wt=xml&indent=true").
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/scigloo-170399.xml"), :headers => {})
      end
      it "should return a valid object" do
        scigloo = Scigloo.find_by_id "170399"
        expect(scigloo.errors.messages.empty?).to be_truthy
      end
      it "should return a valid object with parameters" do
        scigloo = Scigloo.find_by_id "170399"
        expect(scigloo.title.present?).to be_truthy
        expect(scigloo.pubyear.present?).to be_truthy
        # ...
      end
    end
    context "with a no existing id" do
      before :each do
        stub_request(:get, "http://solr.lib.chalmers.se:8080/solr/scigloo/select?q=*%3A*&fq=pubid%3A170399999999&wt=xml&indent=true").
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/scigloo-170399999999.xml"), :headers => {})
      end
      it "should return a invalid object" do
        scigloo = Scigloo.find_by_id "170399999999"
        expect(scigloo.errors.messages.empty?).to be_falsey
      end
    end
    context "with no id" do
      before :each do
        stub_request(:get, "http://solr.lib.chalmers.se:8080/solr/scigloo/select?q=*%3A*&fq=pubid%3A&wt=xml&indent=true").
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/scigloo-nil.xml"), :headers => {})
      end
      it "should return a invalid object" do
        scigloo = Scigloo.find_by_id ""
        expect(scigloo.errors.messages.empty?).to be_falsey
      end
    end
    context "with an invalid id" do
      it "should return nil" do
        scigloo = Scigloo.find_by_id "123 4321"
        expect(scigloo.nil?).to be_truthy
      end
    end
  end
end



require 'rails_helper'

RSpec.describe Pubmed, :type => :model do
  before :each do
    WebMock.disable_net_connect!


  end
  after :each do
    WebMock.allow_net_connect!
  end
  describe "find_by_id" do
    context "with an existing id" do
      before :each do
        stub_request(:get, "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=25505574&retmode=xml").
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/pubmed-25505574.xml"), :headers => {})
      end
      it "should return a valid object" do
        pubmed = Pubmed.find_by_id "25505574"
        expect(pubmed.errors.messages.empty?).to be_truthy
      end
      it "should return a valid object with parameters" do
        pubmed = Pubmed.find_by_id "25505574"
        expect(pubmed.title.present?).to be_truthy
        expect(pubmed.pubyear.present?).to be_truthy
        # ...
      end
    end
    context "with a no existing id" do
      before :each do
        stub_request(:get, "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=255055741354975&retmode=xml").
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/pubmed-255055741354975.xml"), :headers => {})
      end
      it "should return a invalid object" do
        pubmed = Pubmed.find_by_id "255055741354975"
        expect(pubmed.errors.messages.empty?).to be_falsey
      end
    end
    context "with no id" do
      before :each do
        stub_request(:get, "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=&retmode=xml").
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/pubmed-nil.xml"), :headers => {})
      end
      it "should return a invalid object" do
        pubmed = Pubmed.find_by_id ""
        expect(pubmed.errors.messages.empty?).to be_falsey
      end
    end
    context "with an invalid id" do
      it "should return nil" do
        pubmed = Pubmed.find_by_id "123 4321"
        expect(pubmed.nil?).to be_truthy
      end
    end
  end
end



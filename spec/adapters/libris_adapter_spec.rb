require 'rails_helper'

RSpec.describe LibrisAdapter, :type => :model do
  before :each do
    WebMock.disable_net_connect!(allow_localhost: true)


  end
  after :each do
    WebMock.allow_net_connect!
  end
  describe "find_by_id" do
    context "with an existing id" do
      before :each do
        stub_request(:get, "http://libris.kb.se/xsearch?format=mods&format_level=full&n=1&query=isbn:(12345)").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'libris.kb.se'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/libris-12345.xml"), :headers => {})

        stub_request(:get, "http://libris.kb.se/xsearch?format=mods&format_level=full&n=1&query=isbn:(12346)").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'libris.kb.se'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/libris-12346.xml"), :headers => {})

        stub_request(:get, "http://libris.kb.se/xsearch?format=mods&format_level=full&n=1&query=isbn:(978-91-637-1542-6)").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'libris.kb.se'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/libris-978-91-637-1542-6.xml"), :headers => {})
      end
      it "should return a valid object" do
        libris = LibrisAdapter.find_by_id "12345"
        expect(libris.errors.messages.empty?).to be_truthy
      end
      it "should return a valid object with parameters" do
        libris = LibrisAdapter.find_by_id "978-91-637-1542-6"
        expect(libris.title.present?).to be_truthy
        expect(libris.pubyear.present?).to be_truthy
        # ...
      end
      it "should return an object wit publication_identifiers" do
        libris = LibrisAdapter.find_by_id "12345"
        expect(libris.publication_identifiers.count).to eq 1
        expect(libris.publication_identifiers.first[:identifier_code]).to include('libris')
        expect(libris.publication_identifiers.first[:identifier_value]).to include('5365951')
      end
      it "should provide a hash of jsonable data" do
        libris = LibrisAdapter.find_by_id "12345"
        expect(libris.json_data).to be_kind_of(Hash)
        expect(libris.json_data[:title]).to be_present
      end
      it "should be able to read data in non-UTF-8 format" do
        libris = LibrisAdapter.find_by_id "12346"
        expect(libris.json_data).to be_kind_of(Hash)
        expect(libris.json_data[:title]).to be_present
      end
      it "should provide a list of authors" do
        libris = LibrisAdapter.find_by_id "12345"
        xml = Nokogiri::XML(libris.xml)
        xml.remove_namespaces!
        expect(LibrisAdapter.authors(xml)).to be_kind_of(Array)
        expect(LibrisAdapter.authors(xml).first[:first_name]).to be_present
      end
      it "should provide a publication type suggestion" do
        libris = LibrisAdapter.find_by_id "12345"
        xml = Nokogiri::XML(libris.xml)
        xml.remove_namespaces!
        expect(LibrisAdapter.publication_type_suggestion(xml)).to eq("publication_book")
      end

    end
    context "with a no existing id" do
      before :each do
        stub_request(:get, "http://libris.kb.se/xsearch?format=mods&format_level=full&n=1&query=isbn:(978-91-637-1542-6123456789)").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'libris.kb.se'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/libris-978-91-637-1542-6123456789.xml"), :headers => {})
      end
      it "should return a invalid object" do
        libris = LibrisAdapter.find_by_id "978-91-637-1542-6123456789"
        expect(libris.errors.messages.empty?).to be_falsey
      end
    end
    context "with no id" do
      before :each do
        stub_request(:get, "http://libris.kb.se/xsearch?format=mods&format_level=full&n=1&query=isbn:()").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'libris.kb.se'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/libris-nil.xml"), :headers => {})
      end
      it "should return a invalid object" do
        libris = LibrisAdapter.find_by_id ""
        expect(libris.errors.messages.empty?).to be_falsey
      end
    end
  end
end



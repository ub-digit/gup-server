require 'rails_helper'

RSpec.describe Libris, :type => :model do
  before :each do
    WebMock.disable_net_connect!


  end
  after :each do
    WebMock.allow_net_connect!
  end
  describe "find_by_id" do
    context "with an existing id" do
      before :each do
        stub_request(:get, "http://libris.kb.se/xsearch?format=mods&format_level=full&n=1&query=isbn:(12345)").
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/libris-12345.xml"), :headers => {})

        stub_request(:get, "http://libris.kb.se/xsearch?format=mods&format_level=full&n=1&query=isbn:(978-91-637-1542-6)").
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/libris-978-91-637-1542-6.xml"), :headers => {})
      end
      it "should return a valid object" do
        libris = Libris.find_by_id "12345"
        expect(libris.errors.messages.empty?).to be_truthy
      end
      it "should return a valid object with parameters" do
        libris = Libris.find_by_id "978-91-637-1542-6"
        expect(libris.title.present?).to be_truthy
        expect(libris.pubyear.present?).to be_truthy
        # ...
      end
    end
    context "with a no existing id" do
      before :each do
        stub_request(:get, "http://libris.kb.se/xsearch?format=mods&format_level=full&n=1&query=isbn:(978-91-637-1542-6123456789)").
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/libris-978-91-637-1542-6123456789.xml"), :headers => {})
      end
      it "should return a invalid object" do
        libris = Libris.find_by_id "978-91-637-1542-6123456789"
        expect(libris.errors.messages.empty?).to be_falsey
      end
    end
    context "with no id" do
      before :each do
        stub_request(:get, "http://libris.kb.se/xsearch?format=mods&format_level=full&n=1&query=isbn:()").
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/libris-nil.xml"), :headers => {})
      end
      it "should return a invalid object" do
        libris = Libris.find_by_id ""
        expect(libris.errors.messages.empty?).to be_falsey
      end
    end
    context "with an invalid id" do
      it "should return nil" do
        libris = Libris.find_by_id "978 91 637 1542 6123456789"
        expect(libris.nil?).to be_truthy
      end
    end
  end
end



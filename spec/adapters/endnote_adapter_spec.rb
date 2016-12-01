require 'rails_helper'

RSpec.describe EndnoteAdapter, :type => :model do
  before :each do
    WebMock.disable_net_connect!(allow_localhost: true)
    @endnote_record = create(:endnote_article_record)
  end
  after :each do
    WebMock.allow_net_connect!
  end

  describe "find_by_id" do
    context "with an existing id" do

      it "should return at least something" do
        item = EndnoteAdapter.find_by_id(@endnote_record.id)
        expect(item).to_not be nil
      end

      it "should return no errors" do
        item = EndnoteAdapter.find_by_id(@endnote_record.id)
        expect(item.errors.messages.empty?).to be_truthy
      end

      it "should return at an item with a sourceid" do
        item = EndnoteAdapter.find_by_id(@endnote_record.id)

        expect(item.sourceid).to eq @endnote_record.id
        expect(item.datasource).to eq 'endnote'
      end

      it "should return a valid object with parameters" do
        item = EndnoteAdapter.find_by_id(@endnote_record.id)
        expect(item.title.present?).to be_truthy
        expect(item.pubyear.present?).to be_truthy
        # ...
      end

      it "should return an item with publication_identifiers" do
        item = EndnoteAdapter.find_by_id(@endnote_record.id)
        expect(item.publication_identifiers).to_not be nil
        expect(item.publication_identifiers.count).to eq 1
        expect(item.publication_identifiers.first[:identifier_code]).to include('doi')
        expect(item.publication_identifiers.first[:identifier_value]).to include("#{@endnote_record.doi}")
      end

      it "should provide a hash of jsonable data" do
        item = EndnoteAdapter.find_by_id(@endnote_record.id)
        expect(item.json_data).to be_kind_of(Hash)
        expect(item.json_data[:title]).to be_present
        expect(item.json_data[:title]).to eq(@endnote_record.title)
      end

      # it "should be able to read data in non-UTF-8 format" do
      #   item = EndnoteAdapter.find_by_id(@endnote_record.id)
      #   expect(item.json_data).to be_kind_of(Hash)
      #   expect(item.json_data[:title]).to be_present
      # end

      it "should provide a list of authors" do
        rec = create(:endnote_xml_record)
        item = EndnoteAdapter.find_by_id(rec.id)
        xml = Nokogiri::XML(item.xml)
        xml.remove_namespaces!
        expect(EndnoteAdapter.authors(xml)).to be_kind_of(Array)
        expect(EndnoteAdapter.authors(xml).first[:first_name]).to be_present
        expect(EndnoteAdapter.authors(xml).first[:last_name]).to be_present
      end

      it "should provide a publication type suggestion" do
        rec = create(:endnote_xml_record)
        item = EndnoteAdapter.find_by_id(rec.id)
        xml = Nokogiri::XML(item.xml)
        xml.remove_namespaces!
        expect(EndnoteAdapter.publication_type_suggestion(xml)).to eq("publication_journal-article")
      end
    end

    # context "with a no existing id" do
    #   before :each do
    #     stub_request(:get, "http://libris.kb.se/xsearch?format=mods&format_level=full&n=1&query=isbn:(978-91-637-1542-6123456789)").
    #       with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'libris.kb.se'}).
    #       to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/libris-978-91-637-1542-6123456789.xml"), :headers => {})
    #   end
    #   it "should return a invalid object" do
    #     libris = LibrisAdapter.find_by_id "978-91-637-1542-6123456789"
    #     expect(libris.errors.messages.empty?).to be_falsey
    #   end
    # end
    # context "with no id" do
    #   before :each do
    #     stub_request(:get, "http://libris.kb.se/xsearch?format=mods&format_level=full&n=1&query=isbn:()").
    #       with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'libris.kb.se'}).
    #       to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/adapters/libris-nil.xml"), :headers => {})
    #   end
    #   it "should return a invalid object" do
    #     libris = LibrisAdapter.find_by_id ""
    #     expect(libris.errors.messages.empty?).to be_falsey
    #   end
    # end
    # context "with an invalid id" do
    #   it "should return nil" do
    #     libris = LibrisAdapter.find_by_id "978 91 637 1542 6123456789"
    #     expect(libris.nil?).to be_truthy
    #   end
    # end
  end

  describe "add_identifier" do
    context "for an endnote_record with one identifier" do
      it "should add the identifier" do
        rec = create(:endnote_record)
        item = EndnoteAdapter.find_by_id(rec.id)
        item.add_identifier(:value_1, :code_1)
        expect(item.publication_identifiers.count).to eq 1
        expect(item.publication_identifiers.first[:identifier_code]).to be(:code_1)
        expect(item.publication_identifiers.first[:identifier_value]).to be(:value_1)
      end
    end
    context "for an endnote_record with many identifiers" do
      it "should add all identifiers" do
        rec = create(:endnote_record)
        item = EndnoteAdapter.find_by_id(rec.id)
        item.add_identifier(:value_1, :code_1)
        item.add_identifier(:value_2, :code_2)
        item.add_identifier(:value_3, :code_3)
        expect(item.publication_identifiers.count).to eq 3
      end
    end
    context "for an endnote_record with empty identifier" do
      it "should not add the identifier" do
        rec = create(:endnote_record)
        item = EndnoteAdapter.find_by_id(rec.id)
        item.add_identifier('', :code_1)
        expect(item.publication_identifiers.count).to eq 0
      end
    end
  end

  describe "authors" do

    context "for an endnote record with one author" do
      before :each do
        raw_xml = ""
        f = File.open('spec/fixtures/files/test_record_1_author.xml', 'r')
        f.each_line do |line|
          raw_xml += line
        end
        f.close
        @xml = Nokogiri::XML(raw_xml).remove_namespaces!
      end

      it "should return an array with one author" do
        authors = EndnoteAdapter.authors(@xml)

        expect(authors).to_not be_empty
        expect(authors.class).to be Array
        expect(authors.count).to eq 1
      end

      it "should contain the names of the single author" do
        authors = EndnoteAdapter.authors(@xml)

        expect(authors[0][:first_name]).to eq 'N.'
        expect(authors[0][:last_name]).to eq 'Hult'
        expect(authors[0][:full_author_string]).to eq 'Hult, N.'
      end
    end

    context "for an endnote record with many authors" do
      before :each do
        raw_xml = ""
        f = File.open('spec/fixtures/files/test_record_3_authors.xml', 'r')
        f.each_line do |line|
          raw_xml += line
        end
        f.close
        @xml = Nokogiri::XML(raw_xml).remove_namespaces!
      end

      it "should return an array with many authors" do
        authors = EndnoteAdapter.authors(@xml)
        expect(authors).to_not be_empty
        expect(authors.class).to be Array
        expect(authors.count).to eq 3
      end

      it "should contain the names of every author" do
        authors = EndnoteAdapter.authors(@xml)

        expect(authors[0][:first_name]).to eq 'N.'
        expect(authors[0][:last_name]).to eq 'Hult'
        expect(authors[0][:full_author_string]).to eq 'Hult, N.'
        expect(authors[1][:last_name]).to eq 'Chaplin'
        expect(authors[1][:full_author_string]).to eq 'Chaplin, C.'
        expect(authors[2][:first_name]).to eq 'J.'
        expect(authors[2][:last_name]).to eq 'Tomten'
        expect(authors[2][:full_author_string]).to eq 'Tomten, J.'
      end
    end

    context "for an endnote record with no authors" do
      before :each do
        raw_xml = ""
        f = File.open('spec/fixtures/files/test_record_0_authors.xml', 'r')
        f.each_line do |line|
          raw_xml += line
        end
        f.close
        @xml = Nokogiri::XML(raw_xml).remove_namespaces!
      end

      it "should return an array with no authors" do
        authors = EndnoteAdapter.authors(@xml)

        expect(authors.class).to be Array
        expect(authors.count).to eq 0
      end
    end
  end

end

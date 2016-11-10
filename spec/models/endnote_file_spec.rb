require 'rails_helper'

RSpec.describe EndnoteFile, type: :model do

  # RELATIONS

  it {should have_many(:endnote_file_records)}


  # VALIDATIONS

  describe "id" do
    it {should validate_uniqueness_of(:id)}
  end

  describe "create endnote_file" do
    context "when given data is valid" do
      it "should create endnote_file" do
        file = create(:endnote_file)
        expect(file.save).to be_truthy
      end
    end
    context "when given data is not valid" do
      it "should not create endnote_file" do
        file = create(:endnote_file)
        file.username = nil
        expect(file.save).to be_falsey
      end
    end
  end

  describe "add endnote_records to endnote_file" do
    context "when records are uniqe" do
      it "should add the records" do
        file = create(:endnote_file)
        record1 = create(:endnote_record, id: 1, checksum: '111')
        record2 = create(:endnote_record, id: 2, checksum: '222')
        record3 = create(:endnote_record, id: 3, checksum: '333')
        file.endnote_records << record1
        file.endnote_records << record2
        file.endnote_records << record3
        expect(file.save).to be_truthy
      end
    end

  end

  # describe "parse" do
  #   context "trying xml" do
  #     it "should just start parsing" do
  #       file = create(:endnote_file)
  #       file.xml = ''
  #       puts "Current directory: #{Dir.pwd}"
  #       f = File.open('spec/fixtures/files/Testfile.xml', 'r')
  #       puts "File opened"
  #       f.each_line do |line|
  #         file.xml += line
  #       end
  #       f.close
  #       puts "File closed"

  #       pp '-*- force_utf8 -*-'
  #       if !file.xml.force_encoding("UTF-8").valid_encoding?
  #         file.xml = file.xml.force_encoding("ISO-8859-1").encode("UTF-8")
  #       end

  #       puts '---*---*---*---'
  #       pp file.xml
  #       puts '---*---*---*---'

  #       #@xml_file = fixture_file_upload('files/Testfile.xml', 'application/xml')

  #       #file.xml = @xml_file.read
  #       out = file.parse
  #       pp out
  #     end
  #   end
  # end


end

require 'rails_helper'

RSpec.describe EndnoteRecord, type: :model do

  # RELATIONS

  it {should have_many(:endnote_file_records)}


  # VALIDATIONS

  describe "id" do
    it {should validate_uniqueness_of(:id)}
  end

  describe "checksum" do
    it {should validate_uniqueness_of(:checksum)}
  end


  describe "create endnote_record" do
    context "when given data is valid" do
      it "should create endnote_record" do
        record = create(:endnote_record)
        expect(record.save).to be_truthy
      end
    end
    context "when given data is not valid" do
      it "should not create endnote_record" do
        record = create(:endnote_record)
        record.username = nil
        expect(record.save).to be_falsey
      end
    end
    context "when record already exist" do
      it "should not create endnote_record" do
        record1 = build(:endnote_record, checksum: "12345")
        record2 = build(:endnote_record, checksum: "12345")
        expect(record1.save).to be_truthy
        expect(record2.save).to be_falsey
      end
    end

    # context "when last name is blank" do
    #   it "should not create person" do
    #     p1 = Person.new
    #     p1.first_name = "fn"
    #     expect(p1.valid?).to be_falsey
    #   end
    # end
    # context "when year of birth is blank" do
    #   it "should create person" do
    #     p1 = Person.new
    #     p1.first_name = "fn"
    #     p1.last_name = "ln"
    #     expect(p1.valid?).to be_truthy
    #   end
    # end
  end

  describe "publication_identifiers" do
    context "when a when one identifier exist" do
      it "should return an array with one identifier" do
        # #pub_a = create(:published_publication)
        # #pid1 = create(:publication_identifier, publication_version_id: pub_a.current_version_id, identifier_code: 'doi', identifier_value: '99999999')
        # #pid2 = create(:publication_identifier, publication_version_id: pub_a.current_version_id, identifier_code: 'doi', identifier_value: '88888888')
        # #pub_b = create(:publication)
        # #pid3 = create(:publication_identifier, publication_version_id: pub_b.current_version_id, identifier_code: 'doi', identifier_value: '99999999')
        # #pid4 = create(:publication_identifier, publication_version_id: pub_b.current_version_id, identifier_code: 'doi', identifier_value: '88888888')

        # record1 = create(:endnote_record, checksum: "12345", doi: 'doj/1')
        # pub = create(:published_publication)
        # identifier = create(:publication_identifier)
        # identifier = create(:publication_identifier, publication_version_id: pub.current_version_id, identifier_code: 'doi', identifier_value: 'doj/1')
        # #identifier.update_attribute(:identifier_code, 'doi')
        # #identifier.update_attribute(:identifier_value, 'doj/1')
        # #identifier.update_attribute(:publication_version_id, pub.current_version_id)
        # record1.update_attribute(:publication_id, pub.id)
        # #pp "record1:"
        # #pp record1

        record = create(:endnote_record, checksum: "12345", doi: 'doj/1')
        #pp "record2:"
        #pp record2
        expect(record.publication_identifiers()).to_not be_empty
        #expect(record2.publication_identifiers())
        pp record.publication_identifiers().first()
        # pp record1.publication_identifiers().first()
        expect(record.publication_identifiers().first()[:identifier_code]).to eq 'doi'
        expect(record.publication_identifiers().first()[:identifier_value]).to eq 'doj/1'
      end
    end
    context "when a no identifier exist" do
      it "should return an empty array" do
        # #pub_a = create(:published_publication)
        # #pid1 = create(:publication_identifier, publication_version_id: pub_a.current_version_id, identifier_code: 'doi', identifier_value: '99999999')
        # #pid2 = create(:publication_identifier, publication_version_id: pub_a.current_version_id, identifier_code: 'doi', identifier_value: '88888888')
        # #pub_b = create(:publication)
        # #pid3 = create(:publication_identifier, publication_version_id: pub_b.current_version_id, identifier_code: 'doi', identifier_value: '99999999')
        # #pid4 = create(:publication_identifier, publication_version_id: pub_b.current_version_id, identifier_code: 'doi', identifier_value: '88888888')

        # record1 = create(:endnote_record, checksum: "12345", doi: 'doj/1')
        # pub = create(:published_publication)
        # identifier = create(:publication_identifier)
        # identifier = create(:publication_identifier, publication_version_id: pub.current_version_id, identifier_code: 'doi', identifier_value: 'doj/1')
        # #identifier.update_attribute(:identifier_code, 'doi')
        # #identifier.update_attribute(:identifier_value, 'doj/1')
        # #identifier.update_attribute(:publication_version_id, pub.current_version_id)
        # record1.update_attribute(:publication_id, pub.id)
        # #pp "record1:"
        # #pp record1

        record = create(:endnote_record, checksum: "12345")
        #pp "record2:"
        #pp record2
        expect(record.publication_identifiers()).to be_empty
        #expect(record2.publication_identifiers())
        pp record.publication_identifiers()
        # pp record1.publication_identifiers().first()
        # expect(record2.publication_identifiers().first()[:identifier_code]).to eq 'doi'
        # expect(record2.publication_identifiers().first()[:identifier_value]).to eq 'doj/2'
      end
    end
  end

end

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
end

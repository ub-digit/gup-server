require 'rails_helper'

RSpec.describe PublicationIdentifier, type: :model do

  # RELATIONS
  describe "relations" do
    it {should belong_to(:publication_version)}
  end

  # VALIDATIONS
  describe "publication_version_id" do
    it {should validate_presence_of(:publication_version_id)}
  end

  describe "identifier_code" do
    it {should validate_presence_of(:identifier_code)}
    it {should_not allow_value('WRONG').for(:identifier_code)}
    it {should allow_value('pubmed').for(:identifier_code)}
  end

  describe "identifier_value" do
    it {should validate_presence_of(:identifier_value)}
  end

  # METHODS
  describe "get_label" do
    context "for a configured identifier code" do
      it "should return label" do
        pi = build(:publication_identifier, identifier_code: 'pubmed')

        result = pi.get_label

        expect(result).to eq "Pubmed-ID"
      end
    end
    context "for a non-configured identifier code" do
      it "should return an error text" do
        pi = build(:publication_identifier, identifier_code: 'nonexist')

        result = pi.get_label

        expect(result).to eq "MISSING: nonexist"
      end
    end
  end

  describe "as_json" do
    it "should contain identifier_label" do
      pi = build(:publication_identifier, identifier_code: 'pubmed')

      json = pi.as_json

      expect(json[:identifier_label]).to eq "Pubmed-ID"
      expect(json['identifier_code']).to eq 'pubmed'
    end
  end
end

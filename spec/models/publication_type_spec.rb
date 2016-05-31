require 'rails_helper'

RSpec.describe PublicationType, :type => :model do

  # RELATIONS
  describe "relations" do
    it {should have_many(:fields2publication_types)}
    it {should have_many(:fields)}
  end

  # VALIDATIONS
  describe "code" do
    subject{build(:publication_type)}
    it {should validate_presence_of(:code)}
    it {should validate_uniqueness_of :code}
  end
  describe "ref_options" do
    it {should validate_presence_of(:ref_options)}
    it {should validate_inclusion_of(:ref_options).in_array(['ISREF', 'NOTREF', 'BOTH', 'NA'])}
  end

  # METHODS
  describe "as_json" do
    it "should include certain methods" do
      pt = build(:publication_type, code: "PubType1", ref_options: "NA")

      json = pt.as_json

      expect(json['name']).to eq pt.name
      expect(json['description']).to eq pt.description
      expect(json['ref_select_options']).to eq pt.ref_select_options
    end
  end

  describe "name" do
    it "should return translated name" do
      pt = build(:publication_type, code: 'pubtype')

      result = pt.name

      expect(result).to eq I18n.t('publication_types.pubtype.label')
    end
  end

  describe "description" do
    it "should return translated description" do
      pt = build(:publication_type, code: 'pubtype')

      result = pt.description

      expect(result).to eq I18n.t('publication_types.pubtype.description')
    end
  end

  describe "active_fields" do
    context "for a publication_version type" do
      it "should return an array of fields" do
        pt = build(:test_publication_type)

        result = pt.active_fields.to_a

        expect(result.first[:name]).to eq 'required'
      end
    end
  end
end

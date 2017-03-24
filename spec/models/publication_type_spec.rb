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
      pt = build(:publication_type, code: 'pubtype', label_sv: "Name Sv")

      result = pt.name

      expect(result).to eq pt.name
    end
  end

  describe "description" do
    it "should return translated description" do
      pt = build(:publication_type, code: 'pubtype', description_sv: "Description Sv")

      result = pt.description

      expect(result).to eq pt.description
    end
  end

  describe "permitted_fields" do
    context "for a publication_type containing title field and array field" do
      it "should return an array of fields" do
        pt = create(:publication_type)
        field = create(:field, name: 'title')
        field2 = create(:field, name: 'category_hsv_local')
        f2p1 = create(:fields2publication_type, publication_type: pt, field: field, rule: 'R')
        f2p2 = create(:fields2publication_type, publication_type: pt, field: field2, rule: 'O')

        result = pt.permitted_fields

        expect(result.size).to eq 2
        expect(result).to include :title
        expect(result[1][:category_hsv_local]).to be_an Array
      end
    end
  end

  describe "validate_publication_version" do
    context "for a required field filled in" do
      it "should not create any error mesages" do
        pv = create(:published_publication).current_version
        pt = pv.publication_type
        pv.title = "Title"

        pt.validate_publication_version(pv)

        expect(pv.validate).to be true
      end
    end
    context "for a required field missing" do
      it "should create an error message" do
        pv = create(:published_publication).current_version
        pt = pv.publication_type
        pv.title = ''

        pt.validate_publication_version(pv)

        expect(pv.validate).to be false
        expect(pv.errors).to have_key :title
      end
    end
    context "for an invalid ref_value" do
      it "should create an error message" do
        pv = create(:published_publication).current_version
        pt = pv.publication_type
        pv.ref_value = "ISREF"

        pt.validate_publication_version(pv)

        expect(pv.validate).to be false
        expect(pv.errors).to have_key :ref_value
      end
    end
    context "for a valid ref_value" do
      it "should not create an error message" do
        pv = create(:published_publication).current_version
        pt = pv.publication_type
        pv.ref_value = "NA"

        pt.validate_publication_version(pv)

        expect(pv.validate).to be true
      end
    end
  end

  describe "valid ref_values" do
    context "for ref_options = BOTH" do
      it "should return [ISREF, NOTREF]" do
        pt = build(:publication_type, ref_options: "BOTH")

        result = pt.valid_ref_values

        expect(result).to eq ['ISREF', 'NOTREF']
      end
    end
    context "for ref_options = NA" do
      it "should return NA" do
        pt = build(:publication_type, ref_options: "NA")

        result = pt.valid_ref_values

        expect(result).to eq ['NA']
      end
    end
    context "for ref_options = ISREF" do
      it "should return ISREF" do
        pt = build(:publication_type, ref_options: "ISREF")

        result = pt.valid_ref_values

        expect(result).to eq ['ISREF']
      end
    end
    context "for ref_options = NOTREF" do
      it "should return NOTREF" do
        pt = build(:publication_type, ref_options: "NOTREF")

        result = pt.valid_ref_values

        expect(result).to eq ['NOTREF']
      end
    end
  end

  describe "ref_select_options" do
    it "should return select objects based on ref_options" do
      pt = build(:publication_type, ref_options: "BOTH")

      result = pt.ref_select_options

      expect(result[0][:value]).to eq 'ISREF'
      expect(result[1][:value]).to eq 'NOTREF'
      expect(result.size).to eq 2
    end
  end

end

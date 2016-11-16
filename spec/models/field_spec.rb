require 'rails_helper'

RSpec.describe Field, type: :model do
  # RELATIONS
  describe "relations" do
    it {should have_many(:fields2publication_types)}
    it {should have_many(:publication_types)}
  end

  # VALIDATIONS
  describe "name" do
    it {should validate_presence_of(:name)}
    it {should validate_uniqueness_of(:name)}
  end

  # METHODS
  describe "label" do
    it "should return a translated name" do
      field = build(:field, name: 'testName')

      expect(field.label).to eq I18n.t("fields.testName")
    end
  end

  describe "is_array?" do
    context "for a field included in ARRAY_FIELDS" do
      it "should return true" do
        field = build(:field, name: 'category_hsv_local')

        expect(field.is_array?).to be_truthy
      end
    end
    context "for a field NOT included in ARRAY_FIELDS" do
      it "should return false" do
        field = build(:field, name: 'title')

        expect(field.is_array?).to be_falsey
      end
    end
  end
end


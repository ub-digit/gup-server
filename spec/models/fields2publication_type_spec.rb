require 'rails_helper'

RSpec.describe Fields2publicationType, type: :model do
  
  # RELATIONS
  describe "relations" do
    it {should belong_to(:field)}
    it {should belong_to(:publication_type)}
  end

  # VALIDATIONS
  describe "field" do
    it {should validate_presence_of(:field)}
  end

  describe "publication_type" do
    it {should validate_presence_of(:publication_type)}
  end

  describe "rule" do
    it {should validate_presence_of(:rule)}
    it {should validate_inclusion_of(:rule).in_array(['R', 'O'])}
  end
  
  # METHODS
  describe "as_json" do
    it "should include field name and label" do
      f2p = build(:fields2publication_type)

      json = f2p.as_json

      expect(json[:label]).to eq f2p.field.label
      expect(json[:name]).to eq f2p.field.name
    end
  end
end

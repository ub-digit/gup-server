require 'rails_helper'

RSpec.describe Fields2publicationType, type: :model do
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
end

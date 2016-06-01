require 'rails_helper'

RSpec.describe Source, type: :model do
  describe "name" do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should_not allow_value(' ').for(:name) }
  end
  
  describe "as_json" do
    it "should return json_data as a Hash" do
      source = create(:source)
      json = source.as_json
      expect(json[:name]).to eq(source.name)
    end
  end
end

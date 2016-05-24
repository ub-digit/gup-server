require 'rails_helper'

RSpec.describe Field, type: :model do
  describe "name" do
    it {should validate_presence_of(:name)}
    it {should validate_uniqueness_of(:name)}
  end
end


require 'rails_helper'

RSpec.describe Source, type: :model do
   describe "name" do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should_not allow_value(' ').for(:name) }
  end
end

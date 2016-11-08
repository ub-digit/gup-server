require 'rails_helper'

RSpec.describe EndnoteRecord, type: :model do

  # RELATIONS

  it {should have_many(:endnote_file_records)}


  # VALIDATIONS

  describe "id" do
    it {should validate_uniqueness_of(:id)}
  end
end

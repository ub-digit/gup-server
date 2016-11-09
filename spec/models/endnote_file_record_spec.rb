require 'rails_helper'

RSpec.describe EndnoteFileRecord, type: :model do

  # VALIDATIONS

  describe "id" do
    it {should validate_uniqueness_of(:id)}
  end

end

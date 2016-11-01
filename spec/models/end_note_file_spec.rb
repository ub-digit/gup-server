require 'rails_helper'

RSpec.describe EndNoteFile, type: :model do

  # RELATIONS
  it {should have_many(:end_note_items)}

  # VALIDATIONS
  describe "id" do
    it {should validate_uniqueness_of(:id)}
  end


end

require 'rails_helper'

RSpec.describe AlternativeName, type: :model do
    before :each do
      @person = create(:xkonto_person)
      @altname = create(:alternative_name, person: @person)
    end
    
    it "should return a normal json hash" do
      json = AlternativeName.find_by_id(@altname.id).as_json
      expect(json).to be_kind_of(Hash)
      expect(json[:first_name]).to eq(@altname.first_name)
      expect(json[:last_name]).to eq(@altname.last_name)
    end
end

require 'rails_helper'

RSpec.describe V1::UserdataController, type: :controller do
  describe "show" do
    it "should return zero-count to review if nothing published" do
      get :show, id: 999999, api_key: @api_key
      expect(json['userdata']).to_not be_nil
      expect(json['userdata']['counts']['review']).to eq(0)
    end

    it "should return non-zero-count to review if publication to review exist" do
      publication = create(:publication, pubid: 101)
      person = create(:person)
      people2publication = create(:people2publication, publication: publication, person: person)
      department = create(:department)
      create(:departments2people2publication, people2publication: people2publication, department: department)

      get :show, id: person.id, api_key: @api_key
      expect(json['userdata']).to_not be_nil
      expect(json['userdata']['counts']['review']).to eq(1)
    end
  end
end

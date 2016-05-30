require 'rails_helper'

RSpec.describe V1::UserdataController, type: :controller do
  describe "show" do
    it "should return zero-count to review if nothing published" do
      get :show, xkonto: 999999, api_key: @api_key
      expect(json['userdata']).to_not be_nil
      expect(json['userdata']['counts']['review']).to eq(0)
    end

    it "should return non-zero-count to review if publication to review exist" do
      publication = create(:published_publication)
      person = create(:xkonto_person)
      people2publication = create(:people2publication, publication_version: publication.current_version, person: person)
      department = create(:department)
      create(:departments2people2publication, people2publication: people2publication, department: department)

      get :show, xkonto: 'xtest', api_key: @xtest_key
      expect(json['userdata']).to_not be_nil
      expect(json['userdata']['counts']['review']).to eq(1)
    end
  end
end

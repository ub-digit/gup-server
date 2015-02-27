require 'rails_helper'

RSpec.describe UsersController, :type => :controller do
  describe "create" do
    it "should create a complete user object" do
      post :create, user: { username: "testuser", first_name: "Test", last_name: "User", role: "ADMIN"}
      expect(json).to have_key("user")
      expect(json["user"]).to have_key("id")
      expect(json["user"]["id"]).to be_present
    end

    it "should fail on missing parameters" do 
      post :create, user: { first_name: "Test", last_name: "User", role: "ADMIN"}
      expect(response.status).to eq(422)
      expect(json).to_not have_key("user")
      expect(json).to have_key("error")
    end
  end
end

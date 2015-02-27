require 'rails_helper'

RSpec.describe UsersController, :type => :controller do
  describe "show" do
    before :each do
      @user = User.create(username: "testuser", first_name: "Test", last_name: "User", role: "ADMIN")
    end

    it "should return a complete user object" do
      get :show, id: @user.id
      expect(json).to have_key("user")
      expect(json["user"]).to have_key("id")
      expect(json["user"]).to have_key("username")
      expect(json["user"]).to have_key("first_name")
      expect(json["user"]).to have_key("last_name")
      expect(json["user"]).to have_key("role")
      expect(json["user"]["username"]).to eq("testuser")
      expect(json["user"]["first_name"]).to eq("Test")
      expect(json["user"]["last_name"]).to eq("User")
      expect(json["user"]["role"]).to eq("ADMIN")
    end

    it "should return user when fetched by username" do
      get :show, id: "testuser"
      expect(json).to have_key("user")
      expect(json["user"]).to have_key("id")
      expect(json["user"]).to have_key("first_name")
      expect(json["user"]).to have_key("last_name")
      expect(json["user"]["first_name"]).to eq("Test")
      expect(json["user"]["last_name"]).to eq("User")
    end

    it "should return 404 when user does not exist" do
      get :show, id: 999999999999
      expect(response.status).to eq(404)
    end
  end
  
  describe "create" do
    it "should create a complete user object" do
      post :create, user: { username: "testuser", first_name: "Test", last_name: "User", role: "ADMIN"}
      expect(json).to have_key("user")
      expect(json["user"]).to have_key("id")
      expect(json["user"]["id"]).to be_present
      expect(json).to_not have_key("error")
    end

    it "should fail on missing parameters" do 
      post :create, user: { first_name: "Test", last_name: "User", role: "ADMIN"}
      expect(response.status).to eq(422)
      expect(json).to_not have_key("user")
      expect(json).to have_key("error")
    end
  end

  describe "update" do
    before :each do
      @user = User.create(username: "testuser", first_name: "Test", last_name: "User", role: "ADMIN")
    end

    it "should update an existing user object" do
      post :update, id: @user.id, user: {first_name: "TestNew" }
      expect(json).to have_key("user")
      expect(json["user"]["first_name"]).to eq("TestNew")
      expect(json).to_not have_key("error")
    end

    it "should give 404 for a non-existing user object" do
      post :update, id: 999999999999, user: {first_name: "TestNew" }
      expect(response.status).to eq(404)
    end
 
    it "should give error for setting bad value on existing user object" do
      post :update, id: @user.id, user: {role: "ADMINXX" }
      expect(response.status).to eq(422)
      expect(json).to_not have_key("user")
      expect(json).to have_key("error")
    end
  end
end

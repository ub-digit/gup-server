require 'rails_helper'

RSpec.describe UsersController, :type => :controller do
  describe "list" do
    context "with users" do
      before :each do
        @user1 = User.create(username: "testuser1", first_name: "Test1",
          last_name: "User", role: "ADMIN")
        @user2 = User.create(username: "testuser2", first_name: "Test2",
          last_name: "User", role: "ADMIN")
        @user3 = User.create(username: "testuser3", first_name: "Test3",
          last_name: "User", role: "ADMIN")
      end

      it "should return list of all users" do
        get :index, api_key: @api_key
        expect(json).to have_key("users")
        expect(json["users"]).to be_kind_of(Array)
        expect(json["users"].count).to eq(3)
      end
    end

    context "without users" do
      it "should return empty list" do
        get :index, api_key: @api_key
        expect(json).to have_key("users")
        expect(json["users"]).to be_kind_of(Array)
        expect(json["users"]).to be_empty
      end
    end
  end

  describe "show" do
    before :each do
      @user = User.create(username: "testuser", first_name: "Test", last_name: "User", role: "ADMIN")
    end

    it "should return a complete user object" do
      get :show, id: @user.id, api_key: @api_key
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
      get :show, id: "testuser", api_key: @api_key
      expect(json).to have_key("user")
      expect(json["user"]).to have_key("id")
      expect(json["user"]).to have_key("first_name")
      expect(json["user"]).to have_key("last_name")
      expect(json["user"]["first_name"]).to eq("Test")
      expect(json["user"]["last_name"]).to eq("User")
    end

    it "should return 404 when user does not exist" do
      get :show, id: 999999999999, api_key: @api_key
      expect(response.status).to eq(404)
    end
  end
  
  describe "create" do
    it "should create a complete user object" do
      post :create, user: { username: "testuser", first_name: "Test", last_name: "User", role: "ADMIN"}, api_key: @api_key
      expect(json).to have_key("user")
      expect(json["user"]).to have_key("id")
      expect(json["user"]["id"]).to be_present
      expect(json).to_not have_key("error")
    end

    it "should fail on missing parameters" do 
      post :create, user: { first_name: "Test", last_name: "User", role: "ADMIN"}, api_key: @api_key
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
      post :update, id: @user.id, user: {first_name: "TestNew" }, api_key: @api_key
      expect(json).to have_key("user")
      expect(json["user"]["first_name"]).to eq("TestNew")
      expect(json).to_not have_key("error")
    end

    it "should give 404 for a non-existing user object" do
      post :update, id: 999999999999, user: {first_name: "TestNew" }, api_key: @api_key
      expect(response.status).to eq(404)
    end
 
    it "should give error for setting bad value on existing user object" do
      post :update, id: @user.id, user: {role: "ADMINXX" }, api_key: @api_key
      expect(response.status).to eq(422)
      expect(json).to_not have_key("user")
      expect(json).to have_key("error")
    end
  end
end

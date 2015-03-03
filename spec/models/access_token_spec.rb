require 'rails_helper'

RSpec.describe AccessToken, :type => :model do
  before :each do
    User.create(username: "fakeuser", first_name: "Fake", last_name: "User", role: "ADMIN")
    @user = User.find_by_username("fakeuser")
  end

  describe "create token" do
    it "should save a proper token" do
      at = AccessToken.new(user_id: @user.id, token: SecureRandom.hex, token_expire: Time.now+1.day)
      expect(at.save).to be_truthy
    end

    it "should save a proper token with username only" do
      at = AccessToken.new(username: "xvalid", token: SecureRandom.hex, token_expire: Time.now+1.day)
      expect(at.save).to be_truthy
    end

    it "should require either user_id or username" do
      at = AccessToken.new(token: SecureRandom.hex, token_expire: Time.now+1.day)
      expect(at.save).to be_falsey
    end
  end

  describe "generate_token" do
    it "should return token when user with id is provided" do
      user = User.create(username: "testuser", first_name: "Test", last_name: "User", role: "ADMIN")
      at = AccessToken.generate_token(user)
      expect(at.token).to_not be_nil
    end

    it "should return token when user without id and with username is provided" do
      user = User.new(username: "testuser", role: "User")
      at = AccessToken.generate_token(user)
      expect(at.token).to_not be_nil
    end

    it "should return not return token when user is nil" do
      at = AccessToken.generate_token(nil)
      expect(at).to be_nil
    end

    it "should return not return token when user is object but missing id and username" do
      user = User.new()
      at = AccessToken.generate_token(user)
      expect(at).to be_nil
    end
  end
end

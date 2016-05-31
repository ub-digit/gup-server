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
    
    it "should return a user object for username only tokens" do
      at = AccessToken.new(username: "xvalid", token: SecureRandom.hex, token_expire: Time.now+1.day)
      expect(at.user).to be_kind_of(User)
    end

    it "should return a user object for proper user tokens" do
      at = AccessToken.new(user_id: @user.id, token: SecureRandom.hex, token_expire: Time.now+1.day)
      expect(at.user).to be_kind_of(User)
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
  
  describe "validate token" do
    context "convenience method" do
      it "should give same answer as direct method" do
        user = User.new(username: "testuser", role: "User")
        at = AccessToken.generate_token(user)
        expect(at.validated?).to eq(AccessToken.validate_token(at.token))

        at = AccessToken.generate_token(user)
        at.token_expire = DateTime.now - 2
        expect(at.validated?).to eq(AccessToken.validate_token(at.token))
      end
    end
  end
end

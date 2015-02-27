require 'rails_helper'

RSpec.describe User, :type => :model do
  describe "create" do
    it "should save a proper user object" do
      user = User.new(username: "testuser", first_name: "Test", last_name: "User", role: "ADMIN")
      expect(user.save).to be_truthy
    end

    it "should require username" do
      user = User.new(first_name: "Test", last_name: "User", role: "ADMIN")
      expect(user.save).to be_falsey
    end

    it "should require first_name" do
      user = User.new(username: "testuser", last_name: "User", role: "ADMIN")
      expect(user.save).to be_falsey
    end

    it "should require last_name" do
      user = User.new(username: "testuser", first_name: "Test", role: "ADMIN")
      expect(user.save).to be_falsey
    end

    it "should require role" do
      user = User.new(username: "testuser", first_name: "Test", last_name: "User")
      expect(user.save).to be_falsey
    end
  end
end

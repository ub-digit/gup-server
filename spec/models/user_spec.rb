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
      user.valid?
      expect(user.errors.messages[:username]).to_not be nil
    end

    it {should validate_presence_of(:username)}

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

    it "should have role from predefined list" do
      user = User.new(username: "testuser", first_name: "Test", last_name: "User", role: "ADMINXX")
      expect(user.save).to be_falsey
    end
    
    it "should not allow purely numeric username" do
      user = User.new(username: "12345", first_name: "Test", last_name: "User", role: "ADMIN")
      expect(user.save).to be_falsey
    end

    it "should require alpha-numeric username" do
      user = User.new(username: "test user", first_name: "Test", last_name: "User", role: "ADMIN")
      expect(user.save).to be_falsey
    end
    
    it "should define api roles to have a key" do
      user = User.new(username: "12345", first_name: "Test", last_name: "User", role: "API_KEY")
      expect(user.has_key?).to be_truthy
    end

    it "should handles role rights" do
      user = User.new(username: "12345", first_name: "Test", last_name: "User", role: "ADMIN")
      expect(user.has_right?("administrate")).to be_truthy
      user = User.new(username: "12345", first_name: "Test", last_name: "User", role: "USER")
      expect(user.has_right?("administrate")).to be_falsey
    end

    context "authentication" do
      before :each do 
        stub_request(:get, APP_CONFIG['external_auth_url']+"/xvalid")
          .with(query: {password: "fake_valid_password"})
          .to_return(body: {auth: {yesno: true }}.to_json)
        
        stub_request(:get, APP_CONFIG['external_auth_url']+"/xvalid")
          .with(query: {password: "fake_invalid_password"})
          .to_return(body: {auth: {yesno: false }}.to_json)
      end

      it "should check for override file" do
        user = User.new(username: "xtest", first_name: "Test", last_name: "User", role: "ADMIN")
        FileUtils.rm_f(APP_CONFIG['override_file'])
        expect(user.auth_override_present?).to be_falsey
        FileUtils.touch(APP_CONFIG['override_file'])
        expect(user.auth_override_present?).to_not be_falsey
        FileUtils.rm_f(APP_CONFIG['override_file'])
      end
      
      it "should prevent authentication for usernames not starting with x" do
        user = User.new(username: "12345", first_name: "Test", last_name: "User", role: "ADMIN")
        expect(user.authenticate("irrelevant-password")).to be_falsey
      end
      
      it "should accept authentication for an xaccount regardless of password if override file is in place" do
        user = User.new(username: "xtest", first_name: "Test", last_name: "User", role: "ADMIN")
        FileUtils.touch(APP_CONFIG['override_file'])
        expect(user.authenticate("wrong-password")).to_not be_falsey
        FileUtils.rm_f(APP_CONFIG['override_file'])
      end
      
      it "should accept authentication for an xaccount with proper password if override file is not in place" do
        user = User.new(username: "xvalid", first_name: "Test", last_name: "User", role: "ADMIN")
        FileUtils.rm_f(APP_CONFIG['override_file'])
        expect(user.authenticate("fake_valid_password")).to_not be_falsey
      end

      it "should deny authentication for an xaccount with improper password if override file is not in place" do
        user = User.new(username: "xvalid", first_name: "Test", last_name: "User", role: "ADMIN")
        FileUtils.rm_f(APP_CONFIG['override_file'])
        expect(user.authenticate("fake_invalid_password")).to be_falsey
      end
    end
    
    it "should find all person ids based on the current users username" do
      people = create_list(:xkonto_person, 4)
      user = User.new(username: "xtest", first_name: "Test", last_name: "User", role: "ADMIN")
      person_ids = user.person_ids
      expect(person_ids).to include(people[0].id)
      expect(person_ids).to include(people[1].id)
      expect(person_ids).to include(people[2].id)
      expect(person_ids).to include(people[3].id)
    end
  end
end

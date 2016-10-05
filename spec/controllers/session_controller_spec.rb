require 'rails_helper'

RSpec.describe SessionController, type: :controller do
  before :each do
    WebMock.disable_net_connect!(allow_localhost: true)
    User.create(username: "admin")
    User.create(username: 'fakeuser', first_name: 'Fake', last_name: 'User', role: "ADMIN")

    stub_request(:get, APP_CONFIG['external_auth_url']+"/fakeuser")
      .with(query: {password: "fake_valid_password"})
      .to_return(body: {auth: {yesno: true }}.to_json)

    stub_request(:get, APP_CONFIG['external_auth_url']+"/fakeuser")
      .with(query: {password: "fake_invalid_password"})
      .to_return(body: {auth: {yesno: false }}.to_json)

    stub_request(:get, APP_CONFIG['external_auth_url']+"/xvalid")
      .with(query: {password: "fake_valid_password"})
      .to_return(body: {auth: {yesno: true }}.to_json)

    stub_request(:get, APP_CONFIG['external_auth_url']+"/xvalid")
      .with(query: {password: "fake_invalid_password"})
      .to_return(body: {auth: {yesno: false }}.to_json)

    stub_request(:get, APP_CONFIG['external_auth_url']+"/xinvalid")
      .with(query: {password: "fake_invalid_password"})
      .to_return(body: {auth: {yesno: false }}.to_json)

    stub_request(:get, APP_CONFIG['external_auth_url']+"/guskonto")
      .with(query: {password: "fake_valid_password"})
      .to_return(body: {auth: {yesno: true }}.to_json)

  end
  after :each do
    WebMock.allow_net_connect!
  end

  describe "create session" do
    it "should return access_token for valid user credentials" do
      post :create, username: "fakeuser", password: "fake_valid_password"
      user = User.find_by_username("fakeuser")
      expect(json['access_token']).to be_truthy
      expect(json['token_type']).to eq("bearer")
      expect(json['access_token']).to eq(user.access_tokens.first.token)
    end

    it "should return valid data for a correct x-account that does not exist locally" do
      post :create, username: "xvalid", password: "fake_valid_password"
      user = User.find_by_username("xvalid")
      expect(user).to be_nil
      expect(json['access_token']).to be_truthy
      expect(json['token_type']).to eq("bearer")
      access_token = AccessToken.find_by_token(json['access_token'])
      expect(access_token.username).to eq("xvalid")
    end

    it "should return valid data for a correct x-account that does not exist" do
      post :create, username: "xvalid", password: "fake_valid_password"
      user = User.find_by_username("xvalid")
      expect(user).to be_nil
      expect(json['access_token']).to be_truthy
      expect(json['token_type']).to eq("bearer")
      access_token = AccessToken.find_by_token(json['access_token'])
      expect(access_token.username).to eq("xvalid")
    end

    it "should return 401 with error on invalid user credentials" do
      post :create, username: "fakeuser", password: "fake_invalid_password"
      expect(response.status).to eq(401)
      expect(json['error']).to be_truthy
    end

    it "should return 401 with error on invalid user credentials with non-local valid x-account" do
      post :create, username: "xvalid", password: "fake_invalid_password"
      expect(response.status).to eq(401)
      expect(json['error']).to be_truthy
    end

    it "should return 401 with error on invalid user credentials with non-local invalid x-account" do
      post :create, username: "xinvalid", password: "fake_invalid_password"
      expect(response.status).to eq(401)
      expect(json['error']).to be_truthy
    end

    it "should return 401 with error on valid user credentials with non-local account that is not starting with x" do
      post :create, username: "guskonto", password: "fake_valid_password"
      expect(response.status).to eq(401)
      expect(json['error']).to be_truthy
    end

    it "should return user data on valid credentials" do
      post :create, username: "fakeuser", password: "fake_valid_password"
      user = User.find_by_username("fakeuser")
      expect(json['user']['first_name']).to eq(user.first_name)
      expect(json['user']['last_name']).to eq(user.last_name)
    end

    it "should return role data" do
      post :create, username: "fakeuser", password: "fake_valid_password"
      expect(json['user']['role']['rights']).to include('delete_published')

      post :create, username: "xvalid", password: "fake_valid_password"
      expect(json['user']['role']['rights']).to_not include('delete_published')
    end

    it "should allow the same user to login multiple times, getting different tokens" do
      post :create, username: "fakeuser", password: "fake_valid_password"
      token1 = json['access_token']
      post :create, username: "fakeuser", password: "fake_valid_password"
      token2 = json['access_token']
      get :show, id: token1
      expect(response.status).to eq(200)
      get :show, id: token2
      expect(response.status).to eq(200)
    end
  end
  
  describe "validate session" do
    it "should return ok on valid session and extend expire time" do
      post :create, username: "fakeuser", password: "fake_valid_password"
      token = json['access_token']
      token_object = AccessToken.find_by_token(token)
      first_expire = token_object.token_expire
      get :show, id: token
      expect(json['access_token']).to eq(token)
      token_object = AccessToken.find_by_token(token)
      second_expire = token_object.token_expire
      expect(first_expire).to_not eq(second_expire)
    end

    it "should return ok on valid session without local user" do
      post :create, username: "xvalid", password: "fake_valid_password"
      token = json['access_token']
      token_object = AccessToken.find_by_token(token)
      first_expire = token_object.token_expire
      get :show, id: token
      expect(json['access_token']).to eq(token)
      token_object = AccessToken.find_by_token(token)
      second_expire = token_object.token_expire
      expect(first_expire).to_not eq(second_expire)
    end

    it "should return 401 on invalid session and clear token" do
      post :create, username: "fakeuser", password: "fake_valid_password"
      token = json['access_token']
      token_object = AccessToken.find_by_token(token)
      token_object.update_attribute(:token_expire, Time.now - 1.day)
      get :show, id: token
      expect(response.status).to eq(401)
      expect(json).to have_key("error")
    end

    it "should return user data on valid session" do
      post :create, username: "fakeuser", password: "fake_valid_password"
      user = User.find_by_username("fakeuser")
      get :show, id: json['access_token']
      expect(json['user']['first_name']).to eq(user.first_name)
      expect(json['user']['last_name']).to eq(user.last_name)
    end

    it "should return role data" do
      post :create, username: "fakeuser", password: "fake_valid_password"
      get :show, id: json['access_token']
      expect(json['user']['role']['rights']).to include('delete_published')

      post :create, username: "xvalid", password: "fake_valid_password"
      get :show, id: json['access_token']
      expect(json['user']['role']['rights']).to_not include('delete_published')
    end
  end
end

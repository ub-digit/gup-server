class User < ActiveRecord::Base
  validates_presence_of :username
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :role
  validate :role_valid
  validate :username_valid
  has_many :access_tokens
  DEFAULT_TOKEN_EXPIRE = 1.day

  # Validates that role exists in config file
  def role_valid
    if !Rails.application.config.roles.find{|role| role[:name] == self.role}
      errors.add(:role, "Role does not exist in config")
    end
  end

  def username_valid
    if username && username[/^\d+$/]
      errors.add(:username, "Username cannot be numeric")
    end

    if username && !username[/^[a-zA-Z0-9]+$/]
      errors.add(:username, "Username music be alpha-numeric only")
    end
  end


  # Clear all tokens that have expired
  def clear_expired_tokens
    access_tokens.where("token_expire < ?", Time.now).destroy_all
  end

  # First clear all invalid tokens. Then look for our provided token.
  # If we find one, we know it is valid, and therefor update its validity
  # further into the future
  def validate_token(provided_token)
    clear_expired_tokens
    token_object = access_tokens.find_by_token(provided_token)
    return false if !token_object
    token_object.update_attribute(:token_expire, Time.now + DEFAULT_TOKEN_EXPIRE)
    true
  end

  # Authenticate user
  def authenticate(provided_password)
    uri = URI(Rails.application.config.services[:session][:auth] + "/" + self.username)
    params = { :password => provided_password }
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.get_response(uri)
    json_response = JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)
    if(json_response["auth"]["yesno"])
      token_object = generate_token
      return token_object.token
    end
    false
  end

  # Generate a random token
  def generate_token
    token_hash = SecureRandom.hex
    token_hash.force_encoding('utf-8')
    access_tokens.create(token: token_hash, token_expire: Time.now + DEFAULT_TOKEN_EXPIRE)
  end
end

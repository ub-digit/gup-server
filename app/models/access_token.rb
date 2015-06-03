class AccessToken < ActiveRecord::Base
  belongs_to :user
  
  validate :user_reference
  DEFAULT_TOKEN_EXPIRE = 1.day

  # Call validate_token on itself for convenience
  def validated?
    AccessToken.validate_token(token)
  end

  def user
    return User.new(username: username, role: "USER") if !user_id
    super
  end

  # Clear all tokens that have expired
  def self.clear_expired_tokens
    AccessToken.where("token_expire < ?", Time.now).destroy_all
  end

  # First clear all invalid tokens. Then look for our provided token.
  # If we find one, we know it is valid, and therefor update its validity
  # further into the future
  def self.validate_token(provided_token)
    AccessToken.clear_expired_tokens
    token_object = AccessToken.find_by_token(provided_token)
    return false if !token_object
    token_object.update_attribute(:token_expire, Time.now + DEFAULT_TOKEN_EXPIRE)
    true
  end

  # Generate a random token
  def self.generate_token(user)
    token_hash = SecureRandom.hex
    token_hash.force_encoding('utf-8')
    token_data = {
      token: token_hash,
      token_expire: Time.now + DEFAULT_TOKEN_EXPIRE
    }
    if user && user.id
      token_data[:user_id] = user.id
    elsif user && user.username
      token_data[:username] = user.username
    else
      return nil
    end
    AccessToken.create(token_data)
  end

  def user_reference
    if user_id.blank? && username.blank?
      @errors.add(:user_id, :blank_when_username_blank)
      @errors.add(:username, :blank_when_user_id_blank)
    end
  end
end

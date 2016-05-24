class User < ActiveRecord::Base
  validates_presence_of :username
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :role
  validate :role_valid
  validate :username_valid

  has_many :access_tokens

  # Validates that role exists in config file
  def role_valid
    if !role_data
      errors.add(:role, :invalid)
    end
  end

  # Extract role data from config
  def role_data
    APP_CONFIG['roles'].find { |role| role['name'] == self.role }
  end

  # If role is of type api, we say that it has a key
  def has_key?
    return false if !role_data
    role_data['type'] == 'api'
  end

  def has_right?(right_value)
    role_data["rights"].include? right_value
  end

  def username_valid
    if username && username[/^\d+$/]
      errors.add(:username, :no_numeric)
    end

    if username && !username[/^[a-zA-Z0-9]+$/]
      errors.add(:username, :alphanumeric)
    end
  end

  # Auth override-file
  def auth_override_present?
    if File.exist?(APP_CONFIG['override_file'])
      return true
    else
      return false
    end
  end
  
  # Authenticate user
  def authenticate(provided_password)
    # Check if we have id. If we do not have id, the user does not exist locally,
    # and should only be allowed if starting with 'x'
    return false if !self.id && !self.username[/^x/]

    # If in dev mode, return token
    if Rails.env != 'production' && (ENV['DEVEL_AUTO_AUTH'] == "OK" || auth_override_present?)
      token_object = AccessToken.generate_token(self)
      return token_object.token
    end

    uri = URI(APP_CONFIG['external_auth_url'] + "/" + self.username)
    params = { :password => provided_password }
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.get_response(uri)
    json_response = JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)
    if(json_response["auth"]["yesno"])
      token_object = AccessToken.generate_token(self)
      return token_object.token
    end
    false
  end

  # Returns user ids if username has a valid identifier
  def person_ids
    persons = Person.find_all_from_identifier(source: 'xkonto', identifier: username)
    return nil if persons.blank?
    return persons.map(&:id)
  end

end

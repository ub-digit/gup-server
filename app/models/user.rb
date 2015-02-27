class User < ActiveRecord::Base
  validates_presence_of :username
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :role
  validate :role_valid
  validate :username_valid

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
end

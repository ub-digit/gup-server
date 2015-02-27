class User < ActiveRecord::Base
  validates_presence_of :username
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :role
  validate :role_valid

  # Validates that role exists in config file
  def role_valid
    if !Rails.application.config.roles.find{|role| role[:name] == self.role}
      errors.add(:role, "Role does not exist in config")
    end
  end
end

class Message < ActiveRecord::Base
  validates_inclusion_of :message_type, :in => %w( NEWS ALERT )
end

class Message < ActiveRecord::Base
  validates_inclusion_of :message_type, :in => %w( NEWS ALERT )
  validates_presence_of :message
  validates_presence_of :start_date
end

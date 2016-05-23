require 'rails_helper'

RSpec.describe Message, type: :model do

  describe "message_type" do
    it {should validate_inclusion_of(:message_type).
            in_array(['NEWS','ALERT'])}

  end

  describe "message" do
    it {should validate_presence_of(:message)}
  end

  describe "start_date" do
    it {should validate_presence_of(:start_date)}
  end

end

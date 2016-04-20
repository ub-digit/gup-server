require 'rails_helper'

RSpec.describe Message, type: :model do

  describe "message_type" do
    it {should validate_inclusion_of(:message_type).
            in_array(['NEWS','ALERT'])}

  end

end

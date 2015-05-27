require 'rails_helper'

RSpec.describe People2publication, :type => :model do
  describe "new" do
      it { should validate_presence_of(:publication_id) }
      it { should validate_presence_of(:person_id) }
      it { should validate_presence_of(:position) }
      it { should validate_uniqueness_of(:position).scoped_to(:publication_id) }
  end
end

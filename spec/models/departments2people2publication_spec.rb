require 'rails_helper'

RSpec.describe Departments2people2publication, :type => :model do
  describe "new" do
      it { should validate_presence_of(:people2publication_id) }
      it { should validate_presence_of(:position) }
      it { should validate_uniqueness_of(:position).scoped_to(:people2publication_id) }
  end
end
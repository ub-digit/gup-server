require 'rails_helper'

RSpec.describe Person, :type => :model do

  describe "last name is mandatory" do
    it { should validate_presence_of(:last_name) }
  end

  describe "create person" do
    context "when given data is valid" do
      it "should create person" do
        p1 = Person.new
        p1.first_name = "fn"
        p1.last_name = "ln"
        p1.year_of_birth = 1970
        p1.save!
        expect(p1.first_name).to eq("fn")
        expect(p1.last_name).to eq("ln")
        expect(p1.year_of_birth).to eq(1970)
      end
    end

    context "when last name is blank" do
      it "should not create person" do
        p1 = Person.new
        p1.first_name = "fn"
        expect(p1.valid?).to be_falsey
      end
    end
    context "when year of birth is blank" do
      it "should create person" do
        p1 = Person.new
        p1.first_name = "fn"
        p1.last_name = "ln"
        expect(p1.valid?).to be_truthy
      end
    end
  end

end

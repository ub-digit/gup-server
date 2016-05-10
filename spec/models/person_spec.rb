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

  describe "find by xaccount" do
    context "when xaccount is known" do
      it "should find all people objects with that xaccount" do
        p1 = create(:person)
        create(:xkonto_identifier, person: p1, value: 'xtest')
        p2 = create(:person)
        create(:xkonto_identifier, person: p2, value: 'xtest')
        p3 = create(:person)
        create(:xkonto_identifier, person: p3, value: 'xother')
        people = Person.find_all_from_identifier(source: 'xkonto', identifier: 'xtest')
        pp people.as_json
        expect(people.size).to eq(2)
        expect(people.map(&:id)).to include(p1.id)
        expect(people.map(&:id)).to include(p2.id)
      end
    end
  end
end

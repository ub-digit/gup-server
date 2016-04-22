require 'rails_helper'

RSpec.describe Departments2people2publication, :type => :model do
  describe "new" do
    it { should validate_presence_of(:people2publication) }
    it { should validate_presence_of(:position) }
    it { should validate_uniqueness_of(:position).scoped_to(:people2publication_id) }

    context "for a pubyear within year limits of the department" do
      it "should create the departments2people2publication" do
        publication_version = create(:publication_version, pubyear: 2010)
        department = create(:department, start_year: 2000, end_year: 2012)
        person = create(:person)
        people2publication = create(:people2publication, publication_version: publication_version, person: person)
      
        departments2people2publication = build(:departments2people2publication, people2publication: people2publication, department: department)
        expect(departments2people2publication.save).to be_truthy
      end
    end
    context "for a pubyear outside year limits of the department" do
      it "should not create the departments2people2publication" do
        publication_version = create(:publication_version, pubyear: 2013)
        department = create(:department, start_year: 2000, end_year: 2012)
        person = create(:person)
        people2publication = create(:people2publication, publication_version: publication_version, person: person)
      
        departments2people2publication = build(:departments2people2publication, people2publication: people2publication, department: department)
        expect(departments2people2publication.save).to be_falsey
      end
    end
    context "for a pubyear before start year of the department and end year does not exist" do
      it "should not create the departments2people2publication" do
        publication_version = create(:publication_version, pubyear: 1995)
        department = create(:department, start_year: 2000, end_year: nil)
        person = create(:person)
        people2publication = create(:people2publication, publication_version: publication_version, person: person)
      
        departments2people2publication = build(:departments2people2publication, people2publication: people2publication, department: department)
        expect(departments2people2publication.save).to be_falsey
      end
     
    end
  end
end

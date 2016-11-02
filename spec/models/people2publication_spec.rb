require 'rails_helper'

RSpec.describe People2publication, :type => :model do
  describe "relations" do
    it { should belong_to(:publication_version)}
    it { should belong_to(:reviewed_publication_version)}
    it { should belong_to(:person)}
    it { should have_many(:departments2people2publications)}
  end

  # TODO: Investigate this code. Why does it not pass.
  describe "validations" do
    it { should validate_presence_of(:publication_version) }
    it { should validate_presence_of(:person) }
    it { should validate_presence_of(:position) }
    it { should validate_uniqueness_of(:position).scoped_to(:publication_version_id) }
  end

  describe "as_json" do
    context "without affiliations" do
      it "should return json_data as a Hash" do
        person = create(:xkonto_person)
        json = create(:people2publication, person: person).as_json
        expect(json).to be_kind_of(Hash)
        expect(json['person_id']).to eq(person.id)
        expect(json[:departments2people2publications]).to be_empty
      end
    end

    context "with affiliations" do
      it "should include affiliations in json_data" do
        @person1 = create(:xkonto_person, first_name: "First", year_of_birth: 1970)
        @person2 = create(:xkonto_person, first_name: "Other", year_of_birth: 1971)
        @xaccount = create(:xkonto_identifier, person: @person2, value: 'xother')
        publication = create(:published_publication)
        department = create(:department)
        people2publication = create(:people2publication, publication_version: publication.current_version, person: @person2)
        create(:departments2people2publication, people2publication: people2publication, department: department)

        json = people2publication.as_json
        expect(json[:departments2people2publications]).to_not be_empty
      end
    end
  end
end

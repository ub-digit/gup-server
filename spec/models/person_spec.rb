require 'rails_helper'

RSpec.describe Person, :type => :model do

  # RELATIONS
  describe "relations" do
    it {should have_many(:alternative_names)}
    it {should have_many(:identifiers)}
    it {should have_many(:sources)}
  end
  
  # VALIDATIONS
  describe "validations" do
    it {should validate_presence_of(:last_name)}
  end
  
  # METHODS
  describe "as_json" do
    before :each do
      @person = create(:xkonto_person)
    end
    
    context "for searching" do
      it "should get json_data as a Hash without active publication status" do
        json = Person.find_by_id(@person.id).as_json
        expect(json).to be_kind_of(Hash)
        expect(json[:last_name]).to eq(@person.last_name)
        expect(json).to_not have_key(:has_active_publications)
      end
    end
    
    context "for administrating" do
      it "should get json_data as a Hash with active publication status" do
        json = Person.find_by_id(@person.id).as_json(include_publication_status: true)
        expect(json).to be_kind_of(Hash)
        expect(json[:last_name]).to eq(@person.last_name)
        expect(json).to have_key(:has_active_publications)
      end
    end
  end
  
  describe "find_all_from_identifier" do
    context "when xaccount is known" do
      it "should find all people objects with that xaccount" do
        p1 = create(:person)
        create(:xkonto_identifier, person: p1, value: 'xtest')
        p2 = create(:person)
        create(:xkonto_identifier, person: p2, value: 'xtest')
        p3 = create(:person)
        create(:xkonto_identifier, person: p3, value: 'xother')
        people = Person.find_all_from_identifier(source: 'xkonto', identifier: 'xtest')
        expect(people.size).to eq(2)
        expect(people.map(&:id)).to include(p1.id)
        expect(people.map(&:id)).to include(p2.id)
      end
    end
  end

  describe "presentation_string" do
    before :each do
      @person = create(:xkonto_person, first_name: "First", year_of_birth: 1970)
      @xaccount = create(:xkonto_identifier, person: @person, value: 'xother')
    end

    context "without affiliations" do
      it "should return a string containing name, birthyear and identifiers" do
        p = Person.find_by_id(@person.id).presentation_string()
        
        expect(p).to include(@person.first_name)
        expect(p).to include(@person.last_name)
        expect(p).to include(@person.year_of_birth.to_s)
        expect(p).to include(@xaccount.value)
      end
    end

    context "with affiliations" do
      it "should return a string containing name, birthyear, identifiers and affiliations" do
        affiliations = ["Aff1", "Aff2"]
        p = Person.find_by_id(@person.id).presentation_string(affiliations)
        
        expect(p).to include(@person.first_name)
        expect(p).to include(@person.last_name)
        expect(p).to include(@person.year_of_birth.to_s)
        expect(p).to include(@xaccount.value)
        expect(p).to include(affiliations[0])
        expect(p).to include(affiliations[1])
      end
    end
  end
  
  describe "has_active_publications?" do
    before :each do
      @person1 = create(:xkonto_person, first_name: "First", year_of_birth: 1970)
      @person2 = create(:xkonto_person, first_name: "Other", year_of_birth: 1971)
      @xaccount = create(:xkonto_identifier, person: @person2, value: 'xother')
      publication = create(:published_publication)
      department = create(:department)
      people2publication = create(:people2publication, publication_version: publication.current_version, person: @person2)
      create(:departments2people2publication, people2publication: people2publication, department: department)
    end
    
    context "with active publications" do
      it "should return true" do
        expect(@person2.has_active_publications?).to be true
      end
    end

    context "without active publications" do
      it "should return false" do
        expect(@person1.has_active_publications?).to be false
      end
    end
  end
  
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

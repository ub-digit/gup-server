require 'rails_helper'

RSpec.describe Faculty, type: :model do

  # METHODS
  describe "name" do
    context "for locale :en" do
      before :each do
        I18n.locale = :en
      end
      it "should return english name" do
        faculty = build(:faculty, name_en: "English name", name_sv: "Svenskt namn")

        expect(faculty.name).to eq "English name"
      end
    end
    context "for locale :sv" do
      before :each do
        I18n.locale = :sv
      end
      it "should return swedish name" do
        faculty = build(:faculty, name_en: "English name", name_sv: "Svenskt namn")

        expect(faculty.name).to eq "Svenskt namn"
      end
    end
  end

  describe "as_json" do
    it "should include name" do
      I18n.locale = :en
      faculty = build(:faculty, name_en: "English name", name_sv: "Svenskt namn")

      json = faculty.as_json

      expect(json[:name]).to eq "English name"
      expect(json['name_en']).to eq "English name"
    end
  end

  describe "name_by_id" do
    before :each do
      I18n.locale = :en
    end
    context "for a given id" do
      context "for an existing faculty" do
        it "should return faculty name" do
          create(:faculty, id: 123, name_en: "FacultyName")

          res = Faculty.name_by_id(123)

          expect(res).to eq "FacultyName"
        end
      end
      context "for a non existing faculty" do
        it "should return an error text" do
          res = Faculty.name_by_id(123)

          expect(res).to eq I18n.t('faculty.not_found')
        end
      end
    end
    context "for a non given id" do
      it "should return an error text" do
        res = Faculty.name_by_id

        expect(res).to eq I18n.t('faculty.unspecified')
      end
    end
  end

end

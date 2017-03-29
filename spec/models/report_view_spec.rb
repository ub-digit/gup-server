require 'rails_helper'

RSpec.describe ReportView, type: :model do
  context "validations" do
    it "should validate a correct column_list" do
      column_list = ["publication_id", "faculty_id"]
      expect(ReportView.columns_valid?(column_list)).to be_truthy
    end

    it "should not validate a column_list with any bad column names" do
      column_list = ["publication_id", "faculty_id", "not-a-column"]
      expect(ReportView.columns_valid?(column_list)).to be_falsey
    end
  end

  context "json" do
    before :each do
      @person = create(:xkonto_person)
      @publication_type = create(:publication_type, code: 'publication_journal-article', label_sv: "Artikel i vetenskaplig tidskrift", label_en: "Journal article")
      @publication = create(:published_publication, current_version: create(:publication_version, publication_type: @publication_type))
      create(:published_publication)
      people2publication = create(:people2publication, publication_version: @publication.current_version, person: @person)
      @department = create(:department)
      create(:departments2people2publication, people2publication: people2publication, department: @department)
    end

    it "should return a normal json hash" do
      json = ReportView.first.as_json
      expect(json['publication_id']).to eq(@publication.id)
      expect(json['publication_version_id']).to eq(@publication.current_version_id)
      expect(json['person_id']).to eq(@person.id)
    end

    it "should return a matrix of data when requested" do
      json = ReportView.first.as_json(matrix: ["faculty_id", "department_id", "person_id", "publication_type_id"])
      expect(json).to be_kind_of(Array)
      expect(json[0]).to eq(["Ingen fakultet", nil])
      expect(json[1]).to eq([@department.name_sv, @department.id])
      expect(json[2]).to eq(@person.id)
      expect(json[3]).to eq([@publication_type.name, @publication_type.id])
    end

    it "should return english names in matrix when locale set to en" do
      old = I18n.locale
      I18n.locale = :en
      json = ReportView.first.as_json(matrix: ["faculty_id", "department_id", "person_id", "publication_type_id"])
      expect(json).to be_kind_of(Array)
      expect(json[0]).to eq(["No faculty specified", nil])
      expect(json[1]).to eq([@department.name_en, @department.id])
      expect(json[2]).to eq(@person.id)
      expect(json[3]).to eq([@publication_type.name, @publication_type.id])
      I18n.locale = old
    end
  end
end

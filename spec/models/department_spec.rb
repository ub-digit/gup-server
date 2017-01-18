require 'rails_helper'

RSpec.describe Department, type: :model do

  describe "name_sv" do
    it {should validate_presence_of(:name_sv)}
  end

  describe "name_en" do
    it {should validate_presence_of(:name_en)}
  end

  describe "start_year" do
    it {should validate_presence_of(:start_year)}
    it {should allow_value(1985).for(:start_year)}
  end

  describe "end_year" do
    it {should_not allow_value(1899).for(:end_year)}
    it {should_not allow_value(10000).for(:end_year)}

    it "should not predate start_year" do
      dep = build(:department, start_year: 1985, end_year: 1984)
      dep.valid?
      expect(dep.errors.messages[:end_year]).to include I18n.t("departments.error.end_year_invalid")
    end
  end

  describe "is_external?" do
    context "for an internal department" do
      it "should return false" do
      department = create(:department)
      ext = Department.find_by_id(department.id).is_external?
      expect(ext).to eq(false)
      end
    end
    context "for an external department" do
      it "should return true" do
      department = create(:external_department)
      ext = Department.find_by_id(department.id).is_external?
      expect(ext).to eq(true)
      end
    end
  end

  describe "as_json" do
    it "should return a normal json hash" do
      department = create(:department)
      json = Department.find_by_id(department.id).as_json
      expect(json).to be_kind_of(Hash)
      expect(json[:name_sv]).to eq(department.name_sv)
    end
  end
end

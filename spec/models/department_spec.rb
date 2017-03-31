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
    it "should include parent if any" do
      parent_department = create(:department)
      department = create(:department, parentid: parent_department.id)

      json = Department.find_by_id(department.id).as_json

      expect(json).to be_kind_of(Hash)
      expect(json[:parent]).to be_kind_of(Hash)
      expect(json[:parent][:id]).to eq(parent_department.id)
    end
    it "should include grandparent if any" do
      grandparent_department = create(:department)
      department = create(:department, grandparentid: grandparent_department.id)

      json = Department.find_by_id(department.id).as_json

      expect(json).to be_kind_of(Hash)
      expect(json[:grandparent]).to be_kind_of(Hash)
      expect(json[:grandparent][:id]).to eq(grandparent_department.id)
    end
    it "should include children if any" do
      department = create(:department)
      child_department_1 = create(:department, parentid: department.id)
      child_department_2 = create(:department, parentid: department.id)

      json = Department.find_by_id(department.id).as_json

      expect(json).to be_kind_of(Hash)
      expect(json[:children]).to be_kind_of(Array)
      expect(json[:children].first).to be_kind_of(Hash)
      expect(json[:children].length).to eq(2)
    end
    it "should only include id and name where option brief: true" do
      department = create(:department)
      child_department_1 = create(:department, parentid: department.id)
      child_department_2 = create(:department, parentid: department.id)

      json = Department.find_by_id(department.id).as_json(brief: true)

      expect(json).to be_kind_of(Hash)
      expect(json[:id]).to_not be_nil
      expect(json[:name]).to_not be_nil
      expect(json.size).to eq(2)

    end

  end
end

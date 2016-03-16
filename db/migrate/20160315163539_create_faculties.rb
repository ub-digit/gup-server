class CreateFaculties < ActiveRecord::Migration
  def change
    create_table :faculties do |t|
		t.text :name_sv
		t.text :name_en
		t.text :created_by
		t.text :updated_by
		t.timestamps
    end
  end
end

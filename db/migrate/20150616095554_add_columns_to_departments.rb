class AddColumnsToDepartments < ActiveRecord::Migration
  def change
    add_column :departments, :name_sv, :text
    add_column :departments, :name_en, :text
    add_column :departments, :start_year, :integer
    add_column :departments, :end_year, :integer
  end
end

class AddColumnsToDepartment < ActiveRecord::Migration
  def change
  	add_column :departments, :parentid, :text
  	add_column :departments, :grandparentid, :text
  	add_column :departments, :created_by, :text
  	add_column :departments, :updated_by, :text
  	add_column :departments, :staffnotes, :text
  	add_column :departments, :palassoid, :text
  	add_column :departments, :kataguid, :text
  end
end

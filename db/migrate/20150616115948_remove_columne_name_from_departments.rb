class RemoveColumneNameFromDepartments < ActiveRecord::Migration
  def change
    remove_column :departments, :name
  end
end

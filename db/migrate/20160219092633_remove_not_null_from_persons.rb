class RemoveNotNullFromPersons < ActiveRecord::Migration
  def change
  	change_column :people, :updated_at, :datetime, :null => true
  end
end

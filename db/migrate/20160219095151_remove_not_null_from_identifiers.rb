class RemoveNotNullFromIdentifiers < ActiveRecord::Migration
  def change
  	change_column :identifiers, :updated_at, :datetime, :null => true
  end
end

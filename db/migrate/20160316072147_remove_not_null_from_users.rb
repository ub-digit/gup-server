class RemoveNotNullFromUsers < ActiveRecord::Migration
  def change
	change_column :users, :updated_at, :datetime, :null => true
  end
end

class AddColumnToPeople < ActiveRecord::Migration
  def change
    add_column :people, :deleted_at, :datetime
  end
end

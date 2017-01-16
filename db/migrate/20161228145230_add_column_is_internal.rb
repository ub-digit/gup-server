class AddColumnIsInternal < ActiveRecord::Migration
  def change
    add_column :departments, :is_internal, :boolean, default: true
  end
end

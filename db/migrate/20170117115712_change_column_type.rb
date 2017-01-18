class ChangeColumnType < ActiveRecord::Migration
  def change
  	change_column :departments, :parentid, 'integer USING CAST(parentid AS integer)'
  	change_column :departments, :grandparentid, 'integer USING CAST(grandparentid AS integer)'
  end
end

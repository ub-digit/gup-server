class RemoveColumnAffiliated < ActiveRecord::Migration
  def change
    remove_column :people, :affiliated
  end
end

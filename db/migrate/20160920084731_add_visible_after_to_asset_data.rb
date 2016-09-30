class AddVisibleAfterToAssetData < ActiveRecord::Migration
  def change
    add_column :asset_data, :visible_after, :date
  end
end

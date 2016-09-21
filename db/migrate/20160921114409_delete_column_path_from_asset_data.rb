class DeleteColumnPathFromAssetData < ActiveRecord::Migration
  def change
    remove_column :asset_data, :path
  end
end

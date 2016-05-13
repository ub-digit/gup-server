class RemoveCategoryField < ActiveRecord::Migration
  def change
    remove_column :publication_versions, :category_hsv_local
  end
end

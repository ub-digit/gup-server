class ChangeCategoryField < ActiveRecord::Migration
  def change
    remove_column :publications, :category_hsv_local
    add_column :publications, :category_hsv_local, :integer, array: true, default: '{}'
  end
end

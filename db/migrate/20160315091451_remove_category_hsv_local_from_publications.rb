class RemoveCategoryHsvLocalFromPublications < ActiveRecord::Migration
  def change
	remove_column :publications, :category_hsv_local
  end
end

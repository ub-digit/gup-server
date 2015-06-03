class RenameColumn < ActiveRecord::Migration
  def change
    rename_column :publications, :category_type, :content_type
  end
end

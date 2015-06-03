class UpdateTablePublications < ActiveRecord::Migration
  def change
    add_column :publications, :category_type, :text
    remove_column :publications, :publication_type_id
  end
end

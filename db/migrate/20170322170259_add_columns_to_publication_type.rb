class AddColumnsToPublicationType < ActiveRecord::Migration
  def change
    add_column :publication_types, :name_sv, :text
    add_column :publication_types, :name_en, :text
    add_column :publication_types, :description_sv, :text
    add_column :publication_types, :description_en, :text
  end
end

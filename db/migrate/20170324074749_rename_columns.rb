class RenameColumns < ActiveRecord::Migration
  def change
    rename_column :publication_types, :name_sv, :label_sv
    rename_column :publication_types, :name_en, :label_en
  end
end

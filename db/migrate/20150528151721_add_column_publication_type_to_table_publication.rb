class AddColumnPublicationTypeToTablePublication < ActiveRecord::Migration
  def change
    add_column :publications, :publication_type, :text
  end
end

class AddRefValueToPublicationVersion < ActiveRecord::Migration
  def change
    add_column :publication_versions, :ref_value, :string
  end
end

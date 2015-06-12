class AddColumnsToTablePublications < ActiveRecord::Migration
  def change
    add_column :people2publications, :reviewed_at, :timestamp, default: nil
    add_column :people2publications, :reviewed_publication_id, :int, default: nil
  end
end

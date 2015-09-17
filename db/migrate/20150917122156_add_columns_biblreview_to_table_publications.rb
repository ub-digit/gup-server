class AddColumnsBiblreviewToTablePublications < ActiveRecord::Migration
  def change
    add_column :publications, :biblreviewed_at, :datetime, default: nil
    add_column :publications, :biblreviewed_by, :text
  end
end

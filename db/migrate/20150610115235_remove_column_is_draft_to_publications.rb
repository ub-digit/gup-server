class RemoveColumnIsDraftToPublications < ActiveRecord::Migration
  def change
    remove_column :publications, :is_draft
  end
end

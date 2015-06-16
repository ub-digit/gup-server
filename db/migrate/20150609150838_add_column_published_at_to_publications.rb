class AddColumnPublishedAtToPublications < ActiveRecord::Migration
  def change
    add_column :publications, :published_at, :datetime
  end
end

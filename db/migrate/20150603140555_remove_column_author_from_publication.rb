class RemoveColumnAuthorFromPublication < ActiveRecord::Migration
  def change
    remove_column :publications, :author
  end
end

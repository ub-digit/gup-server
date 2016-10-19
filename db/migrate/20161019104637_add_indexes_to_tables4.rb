class AddIndexesToTables4 < ActiveRecord::Migration
  def change
    add_index :asset_data, :publication_id
    add_index :asset_data, :deleted_at
    add_index :access_tokens, :token
    add_index :access_tokens, :token_expire
  end
end

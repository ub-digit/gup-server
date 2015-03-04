class AddUsernameToAccessToken < ActiveRecord::Migration
  def change
    add_column :access_tokens, :username, :text
  end
end

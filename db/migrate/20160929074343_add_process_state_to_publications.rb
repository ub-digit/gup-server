class AddProcessStateToPublications < ActiveRecord::Migration
  def change
    add_column :publications, :process_state, :text
  end
end

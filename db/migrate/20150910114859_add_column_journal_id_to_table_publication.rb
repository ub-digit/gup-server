class AddColumnJournalIdToTablePublication < ActiveRecord::Migration
  def change
    add_column :publications, :journal_id, :integer
  end
end

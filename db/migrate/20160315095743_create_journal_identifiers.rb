class CreateJournalIdentifiers < ActiveRecord::Migration
  def change
    create_table :journal_identifiers do |t|
		t.integer :journal_id
		t.text :identifier_type
		t.text :value
		t.timestamps
    end
  end
end

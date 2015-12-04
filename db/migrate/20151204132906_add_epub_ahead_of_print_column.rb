class AddEpubAheadOfPrintColumn < ActiveRecord::Migration
  def change
    add_column :publications, :epub_ahead_of_print, :datetime, :default => nil
  end
end

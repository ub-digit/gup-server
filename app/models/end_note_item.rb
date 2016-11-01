class EndNoteItem < ActiveRecord::Base
  belongs_to :endnote_files
  belongs_to :publications
end

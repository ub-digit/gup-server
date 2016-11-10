class EndnoteFileRecord < ActiveRecord::Base
  belongs_to :endnote_file
  belongs_to :endnote_record

  validates :id, uniqueness: true
  #validates_uniqueness_of :position, scope: [:endnote_file_id]
  validates_uniqueness_of :endnote_record_id, scope: [:endnote_file_id]
end

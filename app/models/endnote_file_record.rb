class EndnoteFileRecord < ActiveRecord::Base
  has_many :endnote_files
  has_many :endnote_records

  validates :id, uniqueness: true
end

class EndnoteFile < ActiveRecord::Base
  has_many :endnote_file_records
  has_many :endnote_records, through: :endnote_file_records

  validates :id, uniqueness: true
  validates :username, presence: true
  validates :xml, presence: true
end

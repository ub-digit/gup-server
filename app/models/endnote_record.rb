class EndnoteRecord < ActiveRecord::Base
  belongs_to :publications
  has_many :endnote_file_records
  has_many :endnote_files, through: :endnote_file_records

  validates :id, uniqueness: true
  validates :username, presence: true
  validates :checksum, presence: true
end

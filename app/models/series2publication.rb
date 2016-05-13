class Series2publication < ActiveRecord::Base

  belongs_to :publication_version
  belongs_to :serie

  validates :serie, presence: true
  validates :publication_version, presence: true
end

class Categories2publication < ActiveRecord::Base
  belongs_to :category
  belongs_to :publication_version

  validates :category, presence: true
  validates :publication_version, presence: true
end

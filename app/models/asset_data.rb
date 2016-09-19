class AssetData < ActiveRecord::Base
  belongs_to :publication

  validates_presence_of :publication_id
  validates_presence_of :name
  validates_inclusion_of :accepted, in: [true, false]
end
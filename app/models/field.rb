class Field < ActiveRecord::Base
  has_many :fields2publication_types
  has_many :publication_types, :through => :fields2publication_types, :source => "publication_type"
  validates_presence_of :name
  validates_uniqueness_of :name
end

class Serie < ActiveRecord::Base

  has_many :series2publications
  has_many :publication_versions, :through => :series2publications
end

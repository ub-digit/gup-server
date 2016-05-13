class Project < ActiveRecord::Base

  has_many :projects2publications
  has_many :publication_versions, :through => :projects2publications

end

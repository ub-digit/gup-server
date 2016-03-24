class Project < ActiveRecord::Base
	has_many :projects2publications
	has_many :publications, :through => :projects2publications
end
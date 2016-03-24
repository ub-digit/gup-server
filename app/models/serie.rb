class Serie < ActiveRecord::Base
	has_many :series2publications
	has_many :publications, :through => :series2publications
end

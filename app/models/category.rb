class Category < ActiveRecord::Base
 	has_many :categories2publications
 	has_many :publications, :through => :categories2publications
end
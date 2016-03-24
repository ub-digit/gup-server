class Categories2publication < ActiveRecord::Base
	belongs_to :publication
	belongs_to :category
end
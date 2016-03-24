class Series2publication < ActiveRecord::Base
	belongs_to :serie 
	belongs_to :publication
end
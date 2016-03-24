class Projects2publication < ActiveRecord::Base
	belongs_to :project
	belongs_to :publication
end
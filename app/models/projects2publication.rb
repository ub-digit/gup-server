class Projects2publication < ActiveRecord::Base
  belongs_to :project
  belongs_to :publication_version

  validates :project, presence: true
  validates :publication_version, presence: true
end

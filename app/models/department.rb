class Department < ActiveRecord::Base
  has_many :departments2people2publications
end

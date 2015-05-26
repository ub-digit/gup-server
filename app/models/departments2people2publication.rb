class Departments2people2publication < ActiveRecord::Base
  belongs_to :people2publication
  belongs_to :department

  validates :people2publication_id, presence: true
  validates :position, presence: true, uniqueness: { scope: :people2publication_id}
end

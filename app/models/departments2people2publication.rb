class Departments2people2publication < ActiveRecord::Base
  belongs_to :people2publication
  belongs_to :department

  validates :people2publication, presence: true
  validates :position, presence: true, uniqueness: { scope: :people2publication}

  validate :validate_year_limits

  def validate_year_limits
  	if people2publication && department 
      pubyear = people2publication.publication.pubyear
      start_year = department.start_year
      end_year = department.end_year

      if pubyear.present?
      	if start_year.present? && end_year.present? && (pubyear > end_year ||  pubyear < start_year)
          errors.add(:department, :pubyear_outside_department_year_limits)
      	elsif start_year.present? && end_year.blank? && pubyear < start_year
          errors.add(:department, :pubyear_outside_department_year_limits)
      	elsif start_year.blank? && end_year.present? && pubyear > end_year
          errors.add(:department, :pubyear_outside_department_year_limits)
      	end
      end
    end
  end 
end

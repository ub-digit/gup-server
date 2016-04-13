class Department < ActiveRecord::Base
  has_many :departments2people2publications
  validate :end_year_after_start_year
  
  def as_json(opts={})
    return super.merge({
      name: I18n.locale == :en ? name_en : name_sv
    })
  end
  
  def end_year_after_start_year
    if end_year.nil? || start_year.nil?
      return
    end
    if start_year > end_year || end_year < 1900 || end_year > 9999
      errors.add(:end_year, I18n.t("departments.error.end_year_invalid"))
    end
  end
end

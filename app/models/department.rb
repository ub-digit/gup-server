class Department < ActiveRecord::Base
  has_many :departments2people2publications
  validate :end_year_after_start_year
  validates_presence_of :name_sv
  validates_presence_of :name_en
  validates_presence_of :start_year
  validates :end_year, numericality: {allow_nil: true, only_integer: true, greater_than_or_equal_to: 1900, less_than_or_equal_to: 9999}
  
  def as_json(opts={})
    return super.merge({
      name: I18n.locale == :en ? name_en : name_sv
    })
  end
  
  def end_year_after_start_year
    if end_year.nil? || start_year.nil?
      return
    end
    if start_year > end_year
      errors.add(:end_year, I18n.t("departments.error.end_year_invalid"))
    end
  end
end

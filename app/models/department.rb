class Department < ActiveRecord::Base
  has_many :departments2people2publications

  def as_json(opts={})
    return super.merge({
      name: I18n.locale == :en ? name_en : name_sv
    })
  end
end

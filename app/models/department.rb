class Department < ActiveRecord::Base
  has_many :departments2people2publications

  def as_json(opts={})
    return super.merge({
      text: name
    })
  end
end

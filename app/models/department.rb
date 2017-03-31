class Department < ActiveRecord::Base
  has_many :departments2people2publications
  belongs_to :parent, :class_name => 'Department', :foreign_key => 'parentid'
  belongs_to :grandparent, :class_name => 'Department', :foreign_key => 'grandparentid'
  belongs_to :faculty
  has_many :children, :class_name => 'Department', :foreign_key => 'parentid'
  validate :end_year_after_start_year
  validates_presence_of :name_sv
  validates_presence_of :name_en
  validates_presence_of :start_year
  validates :end_year, numericality: {allow_nil: true, only_integer: true, greater_than_or_equal_to: 1900, less_than_or_equal_to: 9999}

  def as_json(opts={})

    res = {
      id: id,
      name: I18n.locale == :en ? name_en : name_sv
    }

    if opts[:brief]
      return res
    end

    res.merge!({
      parent: parent.as_json({skip_children:true}),
      grandparent: grandparent.as_json({skip_children:true}),
      faculty: faculty,
      created_at: created_at,
      updated_at: updated_at,
      name_sv: name_sv,
      name_en: name_en,
      start_year: start_year,
      end_year: end_year,
      faculty_id: faculty_id,
      parentid: parentid,
      grandparentid: grandparentid,
      created_by: created_by,
      updated_by: updated_by,
      staffnotes: staffnotes,
      palassoid: palassoid,
      kataguid: kataguid,
      is_internal: is_internal
    })

    if !opts[:skip_children]
      res[:children] = children.as_json({skip_children:true})
    end
    return res
  end

  def is_external?
    return !self.is_internal
  end

  def name
    if I18n.locale == :en
      return name_en
    else
      return name_sv
    end
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

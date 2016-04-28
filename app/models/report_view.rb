# This is a rails model mapping on top a view. This is not intended
# to produce sane publication lists. Its main purpose is to have a
# place to build groupable queries on, for statistical purposes.
class ReportView < ActiveRecord::Base
  self.primary_key = 'publication_id'

  belongs_to :department
  belongs_to :publication
  belongs_to :publication_version
  belongs_to :person

  def displayed_value(name, value)
    if name == "faculty_id"
      return Faculty.name_by_id(value)
    elsif name == "department_id"
      department = Department.find_by_id(value)
      if !department
        return I18n.t('department.not_found')
      end
      if I18n.locale == :en
        return department.name_en
      else 
        return department.name_sv
      end
    elsif name == "publication_type"
      pubtype = PublicationType.find_by_code(value)
      if !pubtype
        return value
      end
      return pubtype.name
    else
      return value
    end
  end
  
  def as_json(options = {})
    if(options[:matrix])
      data = []
      options[:matrix].each do |column|
        data << displayed_value(column, self.attributes[column])
      end
      return data
    else
      super
    end
  end
end

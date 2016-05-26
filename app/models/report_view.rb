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
      if I18n.locale == :en
        return department.name_en
      else 
        return department.name_sv
      end
    elsif name == "publication_type_id"
      pubtype = PublicationType.find_by_id(value)
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
  
  def self.columns_valid?(column_list)
    db_columns = self.columns.map(&:name)
    missing_columns = column_list - db_columns
    if !missing_columns.blank?
      return false
    end
    return true
  end
end

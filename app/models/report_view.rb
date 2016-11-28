# This is a rails model mapping on top a view. This is not intended
# to produce sane publication lists. Its main purpose is to have a
# place to build groupable queries on, for statistical purposes.
class ReportView < ActiveRecord::Base
  self.primary_key = 'publication_id'

  belongs_to :department
  belongs_to :publication
  belongs_to :publication_version
  belongs_to :person

  def add_displayed_value(name, value)
    if name == "faculty_id"
      return [Faculty.name_by_id(value), value]
    elsif name == "department_id"
      department = Department.find_by_id(value)
      if department
        return [department.name, value]
      else
        return ["Department not found(#{value})", value]
      end
    elsif name == "publication_type_id"
      pubtype = PublicationType.find_by_id(value)
      if pubtype
        return [pubtype.name, value]
      else
        return ["Publication type not found(#{value})", value]
      end
    elsif name == "ref_value"
      return [I18n.t("reports.ref_values.#{value}"), value]
    else
      return value
    end
  end

  def as_json(options = {})
    if(options[:matrix])
      data = []
      options[:matrix].each do |column|
        data << add_displayed_value(column, self.attributes[column])
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

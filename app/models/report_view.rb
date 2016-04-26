# This is a rails model mapping on top a view. This is not intended
# to produce sane publication lists. Its main purpose is to have a
# place to build groupable queries on, for statistical purposes.
class ReportView < ActiveRecord::Base
  self.primary_key = 'publication_id'

  belongs_to :department
  belongs_to :publication
  belongs_to :publication_version
  belongs_to :person

  def as_json(options = {})
    if(options[:matrix])
      data = []
      options[:matrix].each do |column| 
        data << self.attributes[column]
      end
      return data
    else
      super
    end
  end
end

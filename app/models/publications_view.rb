# This is a rails model mapping on top a view. This is not intended
# to produce sane publication lists. Its main purpose is to have a
# place to build groupable queries on, for statistical purposes.
class PublicationsView < ActiveRecord::Base
  self.primary_key = 'id'
  belongs_to :publication, class_name: "Publication", foreign_key: "id"
end

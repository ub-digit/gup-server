class Field < ActiveRecord::Base
  has_many :fields2publication_types
  has_many :publication_types, :through => :fields2publication_types, :source => "publication_type"
  validates_presence_of :name
  validates_uniqueness_of :name

  # Series and Projects are handled separately, and not part of allowed associations
  ARRAY_FIELDS = ['category_hsv_local']

  def label(publication_type: nil)
    if publication_type && I18n.exists?("fields.#{name}_#{publication_type}")
      I18n.t("fields.#{name}_#{publication_type}")
    else
      I18n.t("fields.#{name}")
    end
  end

  def is_array?
    ARRAY_FIELDS.include?(name)
  end
end

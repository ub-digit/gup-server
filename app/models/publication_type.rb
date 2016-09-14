class PublicationType < ActiveRecord::Base

  has_many :fields2publication_types
  has_many :fields, :through => :fields2publication_types, :source => "field"
  validates_presence_of :code
  validates_uniqueness_of :code
  validates_presence_of :ref_options
  validates_inclusion_of :ref_options, in: ['ISREF', 'NOTREF', 'BOTH', 'NA']

  def as_json options={}
    super(options.merge({methods: [:name, :description, :ref_select_options]})).merge({
      all_fields: fields2publication_types.as_json
    })
  end

  def name
    I18n.t("publication_types.#{code}.label")
  end

  def description
    I18n.t("publication_types.#{code}.description")
  end

  def permitted_fields
    fields.map do |field|
      if field.is_array?
        {field.name.to_sym => []}
      else
        field.name.to_sym
      end
    end
  end

  def validate_publication_version(publication_version)
    # Validate required fields
    fields2publication_types.where(rule: 'R').each do |field_relation|
      field = field_relation.field
      value = publication_version.send(field.name)
      if value.blank?
        if field.name == "author" && value.nil? && publication_version.authors.present?
          next
        elsif field.name == "category_hsv_local" && value.nil? && publication_version.categories.present?
          next
        end
        publication_version.errors.add(field.name.to_sym, :field_required, :field_name => name, :publication_type => self.code)
      end
    end

    # Validate ref_value
    if !valid_ref_values.include? (publication_version.ref_value)
      publication_version.errors.add(:ref_value, "Not a valid ref_value for publication_type, valid values are: #{valid_ref_values}")
    end
  end

  def valid_ref_values
   if ref_options == "BOTH"
     return ['ISREF', 'NOTREF']
   else
     return [ref_options]
   end
  end

  def ref_select_options
    options = []
    valid_ref_values.each do |value|
      options << {value: value, label: I18n.t("ref_values.#{value}")}
    end
    return options
  end

end

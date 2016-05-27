class PublicationType < ActiveRecord::Base

  has_many :fields2publication_types
  has_many :fields, :through => :fields2publication_types, :source => "field"
  validates_presence_of :code
  validates_uniqueness_of :code
  validates_presence_of :ref_options
  validates_inclusion_of :ref_options, in: ['ISREF', 'NOTREF', 'BOTH', 'NONE']

  def as_json options={}
    super(options.merge({methods: [:name, :description, :all_fields]}))
  end

  def name
    I18n.t("publication_types.#{code}.label")
  end

  def description
    I18n.t("publication_types.#{code}.description")
  end

  def active_fields
    fields.select(:name)
  end

  def all_fields
    fields2publication_types.as_json
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
    fields2publication_types.where(rule: 'R').each do |field_relation|
      field = field_relation.field
      value = publication_version.send(field.name)
      if value.blank?
        publication_version.errors.add(field.name.to_sym, :field_required, :field_name => name, :publication_type => self.code)
      end
    end
  end

end

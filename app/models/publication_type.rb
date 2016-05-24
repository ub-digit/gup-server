class PublicationType < ActiveRecord::Base

  has_many :fields2publication_types
  has_many :fields, :through => :fields2publication_types, :source => "field"
  validates_presence_of :code
  validates_uniqueness_of :code
  validates_presence_of :ref_options
  validates_inclusion_of :ref_options, in: ['ISREF', 'NOTREF', 'BOTH', 'NONE']

  def name
    I18n.t("publication_types.#{code}.label")
  end

  def description
    I18n.t("publication_types.#{code}.description")
  end

  def active_fields
    fields.select(:name)
  end

  def permitted_params(params, extra_params)
    params.require(:publication).permit(active_fields + extra_params)
  end

  def validate_publication_version(publication_version)
    return true
  end

end

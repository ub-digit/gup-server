class PublicationType

  attr_accessor :all_fields, :code, :content_types

  # Returns a PublicationType object on code
  def self.find_by_code(code)
    if APP_CONFIG['publication_types']
      publication_type_hash = APP_CONFIG['publication_types'].find{|pt| pt['code'] == code}
      return PublicationType.new(publication_type_hash)
    else
      return false
    end
  end

  # Creates a new PublicationType object from config hash
  def initialize(hash)
    @code = hash['code']
    @form_templates = hash['form_templates'] || []
    @fields = hash['fields'] || []
    @content_types = hash['content_types'] || []
    @all_fields = generate_combined_fields
  end

  # Returns a combined array of field objects, based on templates and fields
  def generate_combined_fields
    all_fields = []
    # Loop through each template and merge all fields
    @form_templates.each do |form_template|
      form_template_hash = APP_CONFIG['publication_form_templates'][form_template]
      next if form_template_hash.nil?
      form_template_hash["fields"].each do |field|
        if all_fields.find{|f| f['name'] == field['name']}.nil?
          all_fields << field
        end
      end
    end
    
    # Loop through all defined fields and overwrite potentially existing imported field
    @fields.each do |field|
      existing_field = all_fields.find{|f| f['name'] == field['name']}
      if existing_field.present?
        existing_field['rule'] = field['rule']
      else
        all_fields << field
      end
    end

    # Remove any fields with rule 'na'
    all_fields.delete_if {|field| field['rule'] == 'na'}

    return all_fields
  end

  # Returns all possible field names from config
  def self.get_all_fields
    all_fields = []

    # Add all template fields
    APP_CONFIG['publication_form_templates'].each do |template| 
      template[1]['fields'].each {|field| all_fields << field['name']}
    end

    # Add all publication type fields
    APP_CONFIG['publication_types'].each do |publication_type|
      next if !publication_type['fields']
      publication_type['fields'].each {|field| all_fields << field['name']}
    end

    return all_fields.uniq
  end

  def active_fields
    @all_fields.map{|field| field['name']}
  end

  def permitted_params(params)
    params.require(:publication).permit(active_fields)
  end

  #def validate_publication publication
  #  validate_common publication
  #
  #  if form_template.eql?('article-ref')
  #     validate_article_ref publication
  #  end
  #end

  #def validate_article_ref publication
  #  if publication.sourcetitle.blank?
  #    publication.errors.add(:sourcetitle, 'Needs a sourcetitle')
  #  end
  #end

  #def validate_common publication
  #  if publication.title.blank?
  #    publication.errors.add(:title, 'Needs a title')
  #  end

  #  if publication.pubyear.blank?
  #    publication.errors.add(:pubyear, 'Needs a publication year')
  #  elsif !is_number?(publication.pubyear)
  #    publication.errors.add(:pubyear, 'Publication year must be numerical')
  #  elsif publication.pubyear.to_i < 1500
  #    publication.errors.add(:pubyear, 'Publication year must be within reasonable limits')
  #  end
  #end

  def is_number? obj
    obj.to_s == obj.to_i.to_s
  end
end

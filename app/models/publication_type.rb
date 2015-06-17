class PublicationType
  attr_accessor :all_fields, :code, :content_types

  # Returns a PublicationType object on code
  def self.find_by_code(code)
    if APP_CONFIG['publication_types']
      publication_type_hash = APP_CONFIG['publication_types'].find{|pt| pt['code'] == code}
      return nil if publication_type_hash.nil?
      return PublicationType.new(publication_type_hash)
    else
      return nil
    end
  end

  # Returns a list of all publication types
  def self.all
    pts = []
    APP_CONFIG['publication_types'].each do |pt_hash|
      pts << PublicationType.find_by_code(pt_hash['code'])
    end
    return pts
  end

  # Creates a new PublicationType object from config hash
  def initialize(hash)
    @code = hash['code']
    @name =  I18n.t("publication_types.#{@code}.label")
    @description = I18n.t("publication_types.#{@code}.description")
    @label = @name
    @form_templates = hash['form_templates'] || []
    @fields = hash['fields'] || []
    @content_types = content_type_list(hash['content_types'])
    @all_fields = generate_combined_fields
  end

  def content_type_list(list)
    return [] if list.blank?
    content_types = []
    list.each do |item|
      content_types << {value: item, label: I18n.t('content_types.' + item)}
    end
    return content_types
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
          field_obj = field.dup
          field_obj['label'] = I18n.t('fields.'+field_obj['name'])
          all_fields << field_obj
        end
      end
    end
    
    # Loop through all defined fields and overwrite potentially existing imported field
    @fields.each do |field|
      existing_field = all_fields.find{|f| f['name'] == field['name']}
      if existing_field.present?
        existing_field['rule'] = field['rule']
      else
        field_obj = field.dup
        field_obj['label'] = I18n.t('fields.'+field_obj['name'])
        all_fields << field_obj
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

  def permitted_params(params, extra_params)
    params.require(:publication).permit(active_fields + extra_params)
  end

  # Validate all fields against a publication object
  def validate_publication publication
    @all_fields.each do |field|
      validate_field(publication: publication, name: field['name'], rule: field['rule'])
    end
  end

  # Validate a single fields against a publication object
  def validate_field(publication:, name:, rule:)
    # Validate if field is allowed

    if !active_fields.include?(name)
      publication.errors.add(name.to_sym, :field_not_allowed, :field_name => name, :publication_type => self.code)
    end

    # Validate presence of value if field is required
    if rule == 'R' && (!publication.respond_to?(name.to_sym) || !publication.send(name.to_sym).present?)
      # Temporary fix 
      if name.to_sym.eql?(:authors) && publication.new_authors.present?
        ## do nothing
      else
         publication.errors.add(name.to_sym, :field_required, :field_name => name, :publication_type => self.code)
      end
    end
  end

  def is_number? obj
    obj.to_s == obj.to_i.to_s
  end
end


# Create publication types if they do not exist
if !Rails.env.test? && ENV['CREATE_PUBLICATION_TYPE_DATA']
  require 'pp'
  require 'csv'
 # PublicationType.destroy_all
 # Field.destroy_all
 # Fields2publicationType.destroy_all

  data = CSV.read('gup-pubtypes-for-import.csv')
  pt_codes = data[0].compact
  pts = {}
  pt_codes.each.with_index do |pt_code, index|
    pts[index] = PublicationType.create_with(ref_options: 'BOTH').find_or_create_by(code: pt_code.downcase)
  end

  field_names = data.transpose[0].compact
  fields = {}
  field_names.each.with_index do |field_name, index|
    fields[index] = Field.find_or_create_by(name: field_name.downcase)
  end

  pt_codes.each.with_index do |pt_code, colnum|
    field_names.each.with_index do |field_name, rownum|
      rule = data[rownum+1][colnum+1]
      #pp "Rule is \'#{rule}\' for #{pt_code} #{field_name} #{rownum} #{colnum}"
      if rule != 'O' && rule != 'R'
        next
      else
        Fields2publicationType.find_or_create_by(publication_type: pts[colnum], field: fields[rownum], rule: rule)
      end
    end
  end
end

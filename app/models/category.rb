class Category
  attr_accessor :children
  attr_accessor :svepid, :parent_svepid, :alive, :category_type, :node_type, :category_id
  attr_accessor :en_name, :en_name_path, :parent_en_name, :parent_en_name_path
  attr_accessor :sv_name, :sv_name_path, :parent_sv_name, :parent_sv_name_path
  # Creates a tree structure from a flat array of category items
  def self.create_category_tree(hash = nil)
    if !hash
      hash = APP_CONFIG['categories']
    end
    
   rootElements = hash.select{|x| x['node_type'] == 'root'}
   
   rootObjects = []

   rootElements.each do |rootElement|
     rootObjects << Category.new(with_children: true, hash: rootElement, is_presentation_root: true)
   end
   
   return rootObjects
  end

  def initialize(with_children: false, hash:, is_presentation_root: false)
    @svepid = hash['svepid']
    @parent_svepid = hash['parent_svepid']
    @alive = hash['alive']
    @category_type = hash['category_type']
    @node_type = hash['node_type']
    @category_id = hash['category_id']
    @en_name = hash['en_name']
    @en_name_path = hash['en_name_path']
    @parent_en_name = hash['parent_en_name']
    @parent_en_name_path = hash['parent_en_name_path']
    @sv_name = hash['sv_name']
    @sv_name_path = hash['sv_name_path']
    @parent_sv_name = hash['parent_sv_name']
    @parent_sv_name_path = hash['parent_sv_name_path']
    @is_presentation_root = is_presentation_root
    @children = hash['children']
    find_children if with_children
  end

  def find_children
    if @children.nil?
      child_elements = APP_CONFIG['categories'].select{|x| x['parent_svepid'] == @svepid}
    else
      child_elements = @children.dup
    end
    @children = []
    child_elements.each do |child|
      @children << Category.new(with_children: true, hash: child)
    end
  end

  def as_json(opts = {})
    #res = super.merge({
    #  children: children
    #})

    res = {
      svepid: @svepid,
      name: get_name,
      node_type: @node_type,
      children: children.as_json({light:true})
    }

    if opts[:light]
      return res
    else
      return super.merge(res)
    end

  end

  # Returns name depending on current locale and position in hierarchy
  def get_name
    if @is_presentation_root && I18n.locale == :en
      return @en_name_path
    elsif @is_presentation_root && I18n.locale == :sv
      return @sv_name_path
    elsif !@is_presentation_root && I18n.locale == :en
      return @en_name
    elsif !@is_presentation_root && I18n.locale == :sv
      return @sv_name
    end
  end

  # Returns a single category based on svepid
  def self.find(id)
    APP_CONFIG['categories'].find{|x| x['svepid'] == id.to_i}
  end

  # Returns a flat list of categories based on query, including their children
  def self.find_by_query(query)
    if query.present?
      root_elements = APP_CONFIG['categories'].select{|c| c['sv_name'] =~ /#{query}/i || c['en_name'] =~ /#{query}/i}
    else
      root_elements = APP_CONFIG['categories_tree']
    end
    root_objects = []

    root_elements.each do |root_element|
      root_objects << Category.new(with_children: true, hash: root_element, is_presentation_root: true)
    end

    return root_objects
  end

end

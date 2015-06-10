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
     rootObjects << Category.new(true, rootElement)
   end
   
   return rootObjects
  end

  def initialize(with_children = false, hash)
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
    find_children if with_children
  end

  def find_children
    @children = []
    APP_CONFIG['categories'].select{|x| x['parent_svepid'] == @svepid}.each do |child|
      children << Category.new(true, child)
    end
  end

  def as_json(opts = {})
    super.merge({
      children: children
    })
  end

  # Returns a single category based on svepid
  def self.find(id)
    APP_CONFIG['categories'].find{|x| x['svepid'] == id.to_i}
  end

  # Returns a flat list of categories based on query, including their children
  def self.find_by_query(query)
    root_elements = APP_CONFIG['categories'].select{|c| c['sv_name'] =~ /#{query}/i || c['en_name'] =~ /#{query}/i}
    root_objects = []

    root_elements.each do |root_element|
      root_objects << Category.new(true, root_element)
    end

    return root_objects
  end

end

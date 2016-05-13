class Category < ActiveRecord::Base
  has_many :children
  belongs_to :parent, :class_name => 'Category'
  has_many :children, :class_name => 'Category', :foreign_key => 'parent_id'

  def parent_svepid
    parent.svepid
  end

  def en_name
    name_en
  end

  def sv_name
    name_sv
  end

  def parent_en_name
    parent.name_en
  end

  def parent_en_name_path
    parent.en_name_path
  end

  def parent_sv_name
    parent.name_sv
  end

  def parent_sv_name_path
    parent.sv_name_path
  end

  def name
    if I18n.locale == :en
      name_en
    elsif I18n.locale == :sv
      name_sv
    else
      name_en
    end
  end

  def name_path
    if I18n.locale == :en
      if en_name_path
        return en_name_path + '|' + name_en
      else
        return name_en
      end
    elsif I18n.locale == :sv
      if sv_name_path
        return sv_name_path + '|' + name_sv
      else
        name_sv
      end
    else
      if en_name_path
        return en_name_path + '|' + name_en
      else
        return name_en
      end
    end
  end

  def as_json(opts = {})
    res = {
      id: id,
      svepid: svepid,
      name: name,
      name_path: name_path,
      node_type: node_type,
      children: children.as_json({light:true})
    }

    if opts[:light]
      return res
    else
      return super.merge(res)
    end
  end

  # Returns a flat list of categories based on query, including their children
  def self.find_by_query(query)
    if query.present?
      return Category.where('name_sv ILIKE ? OR name_en ILIKE ?', "%#{query}%", "%#{query}%").where(category_type: 'HSV_LOCAL_12')
    else
      return Category.where(parent_id: nil).where(category_type: 'HSV_LOCAL_12')
    end
  end

  # Returns an array of category objects from array of ids
  def self.find_by_ids(ids)
    Category.where(svepid: ids)
  end
end

class Category < ActiveRecord::Base
  belongs_to :parent, :class_name => 'Category'
  has_many :children, :class_name => 'Category', :foreign_key => 'parent_id'

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
        return en_name_path.split('|').join(' | ') + ' | ' + name_en
      else
        return name_en
      end
    elsif I18n.locale == :sv
      if sv_name_path
        return sv_name_path.split('|').join(' | ') + ' | ' + name_sv
      else
        name_sv
      end
    else
      if en_name_path
        return en_name_path.split('|').join(' | ') + ' | ' + name_en
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
      category_type: category_type,
      children: children.as_json({light: true})
    }

    if opts[:light]
      return res
    else
      return super.merge(res)
    end
  end

  # Returns a flat list of categories based on query, including their children
  def self.find_by_query(query:)
    if query.present?
      categories = self.where('name_sv ILIKE ? OR name_en ILIKE ?', "%#{query}%", "%#{query}%")
    end

    return categories
  end

  # Returns an array of category objects from array of ids
  def self.find_by_ids(ids)
    Category.where(svepid: ids)
  end
end

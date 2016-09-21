class AssetData < ActiveRecord::Base
  belongs_to :publication

  validates_presence_of :publication_id
  validates_presence_of :name

  def is_viewable? token
  	(token == tmp_token || (deleted_at.nil? && !accepted.nil? && (visible_after.nil? || visible_after < Date.today)))
  end
end
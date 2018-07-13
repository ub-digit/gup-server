class EndnoteFile < ActiveRecord::Base
  has_many :endnote_file_records
  has_many :endnote_records, through: :endnote_file_records

  validates :id, uniqueness: true
  validates :username, presence: true
  validates :xml, presence: true

  before_destroy :destroy_endnote_records

  def as_json(options = {})
    json = super
    json.delete('xml')
    # json.merge!(
    #   {
    #     version_id: id,
    #     version_created_at: created_at,
    #     version_created_by: created_by,
    #     version_updated_at: updated_at,
    #     version_updated_by: updated_by
    #   })
    json["endnote_records"] = self.endnote_records.order(:id)
    return json
  end

  private

  def destroy_endnote_records
    ids = []
    endnote_records.each do |rec|
      ids << rec.id
    end

    endnote_records.destroy_all

    ids.each do |id|
      res = EndnoteRecord.find_by(id: id)
      if res
        if res.is_destroyable
          res.destroy
        end
      end
    end
  end

end

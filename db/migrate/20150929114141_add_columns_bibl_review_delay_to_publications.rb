class AddColumnsBiblReviewDelayToPublications < ActiveRecord::Migration
  def change
    add_column :publications, :bibl_review_start_time, :datetime, default: nil
    add_column :publications, :bibl_review_delay_comment, :text
  end
end

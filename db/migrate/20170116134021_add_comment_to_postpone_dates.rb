class AddCommentToPostponeDates < ActiveRecord::Migration
  def change
    add_column :postpone_dates, :comment, :text
  end
end

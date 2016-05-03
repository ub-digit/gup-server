class RemoveBiblreviewPostponedUntilAndBiblreviewPostponedCommentFromPublications < ActiveRecord::Migration
  def change
	remove_column :publications, :biblreview_postponed_until
	remove_column :publications, :biblreview_postpone_comment
  end
end

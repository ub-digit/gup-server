class AssetData < ActiveRecord::Base
  belongs_to :publication

  validates_presence_of :publication_id
  validates_presence_of :name
  validates_presence_of :content_type
  validates_presence_of :checksum

  ## The asset is always viewable when a correct tmp token is provided and tmp token in DB is not nil.
  ## The asses is viewable when it is not deleted and it is accepted and its is not "embargoed"
  def is_viewable?(param_tmp_token:)
    ((!tmp_token.nil? && param_tmp_token == tmp_token) || (publication.is_published? && deleted_at.nil? && !accepted.nil? && (visible_after.nil? || visible_after < Date.today)))
  end

  def is_viewable_by_user?(param_tmp_token:, xaccount:)

    return true if is_viewable?(param_tmp_token: param_tmp_token)

    return true if publication.current_version.created_by == xaccount

    false
  end

  # The asset is deletable is the user is an owner of the asset (se is_owner?)
  # or an admin in the system.
  # The asset licence must be accepted.
  def is_deletable_by_user?(xaccount:)
    user = User.find_by_username(xaccount) || User.new(role: "USER")

    # Only accepted files can be deleted
    return false if accepted.nil?

    # Admin can always delete
    return true if user.has_right?("administrate")

    # Owners of the publication version can delete
    return true if is_owner?(xaccount: xaccount)

    # Others are not allowed
    false
  end

  # Check if user is an owner of the asset object. This is only when the user is an author
  # on the publication the asset is connected to
  # The creator is an owner if the publication is a draft, since
  # there may not yet be an author, and it is only accessible by the creator anyway.
  def is_owner?(xaccount:)
    # DRAFT and creator means owner
    return true if publication.is_draft? && publication.current_version.is_creator?(xaccount: xaccount)

    # Author means owner
    return true if publication.current_version.is_author?(xaccount: xaccount)

    # All others are not owners
    false
  end
end

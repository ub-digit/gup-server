class AssetData < ActiveRecord::Base
  belongs_to :publication

  validates_presence_of :publication_id
  validates_presence_of :name
  validates_presence_of :content_type
  validates_presence_of :checksum

  ## The asset is always viewable when tmp token is provided.
  ## The asses is viewable when it is not deleted and it is accepted and its is not "embargoed"
  def is_viewable? token
  	(token == tmp_token || (deleted_at.nil? && !accepted.nil? && (visible_after.nil? || visible_after < Date.today)))
  end
  
  # The asset is deletable is the user is an owner of the asset (se is_owner?)
  # or an admin in the system.
  # The asset licence must be accepted.
  def is_deletable_by_user?(xaccount: xaccount)
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
  def is_owner?(xaccount: xaccount)
    # DRAFT and creator means owner
    return true if publication.is_draft? && publication.current_version.is_creator?(xaccount: xaccount)
    
    # Author means owner
    return true if publication.current_version.is_author?(xaccount: xaccount)

    # All others are not owners
    false
  end
end

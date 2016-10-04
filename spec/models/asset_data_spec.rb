require 'rails_helper'

RSpec.describe AssetData, :type => :model do
  
  before :each do
    create(:publication, id: 1)
    @publication = Publication.find(1)
  end
  
  it "should save a complete file post" do
    ad = AssetData.new(name: "Test file",
                       content_type: "application/octet-stream",
                       checksum: "7617bbb06b191eac363b108295d1dd9e",
                       tmp_token: "a86e05200b4ee302f836c84e07c94ad6",
                       accepted: nil,
                       visible_after: "2016-10-01",
                       publication_id: @publication.id)
    expect(ad.save).to be_truthy
  end
  
  it "should require publication" do
    ad = AssetData.new(name: "Test file", 
                       content_type: "application/octet-stream",
                       checksum: "7617bbb06b191eac363b108295d1dd9e")
    expect(ad.save).to be_falsey
  end

  it "should require name" do
    ad = AssetData.new(content_type: "application/octet-stream",
                       checksum: "7617bbb06b191eac363b108295d1dd9e",
                       publication_id: @publication.id)
    expect(ad.save).to be_falsey
  end

  it "should require content_type" do
    ad = AssetData.new(name: "Test file",
                       checksum: "7617bbb06b191eac363b108295d1dd9e",
                       publication_id: @publication.id)
    expect(ad.save).to be_falsey
  end
  it "should require name" do
    ad = AssetData.new(content_type: "application/octet-stream",
                       checksum: "7617bbb06b191eac363b108295d1dd9e",
                       publication_id: @publication.id)
    expect(ad.save).to be_falsey
  end
  
  describe "is_viewable?" do
    context "when a correct tmp token is provided" do
      it "should return true" do
        ad = AssetData.create(name: "Test file",
                           content_type: "application/octet-stream",
                           checksum: "7617bbb06b191eac363b108295d1dd9e",
                           tmp_token: "a86e05200b4ee302f836c84e07c94ad6",
                           accepted: nil,
                           publication_id: @publication.id)
        expect(ad.is_viewable? "a86e05200b4ee302f836c84e07c94ad6").to be_truthy
      end  
    end
    context "asset is not deleted and accepted and not embargoed" do
      it "should return true" do
        ad = AssetData.create(name: "Test file",
                           content_type: "application/octet-stream",
                           checksum: "7617bbb06b191eac363b108295d1dd9e",
                           tmp_token: "a86e05200b4ee302f836c84e07c94ad6",
                           accepted: "Test agreement",
                           visible_after: "2016-10-01",
                           publication_id: @publication.id)
        expect(ad.is_viewable? "a86e05200b4ee302f836c84e07c94ad6").to be_truthy
      end  
    end

    context "when asset is deleted" do
      it "should return false" do
        ad = AssetData.create(name: "Test file",
                           content_type: "application/octet-stream",
                           checksum: "7617bbb06b191eac363b108295d1dd9e",
                           tmp_token: "a86e05200b4ee302f836c84e07c94ad6",
                           accepted: "Test agreement",
                           deleted_at: "2016-10-01",
                           publication_id: @publication.id)
        expect(ad.is_viewable? "").to be_falsey
      end  
    end
    context "when asset is not accepted" do
      it "should return false" do
        ad = AssetData.create(name: "Test file",
                           content_type: "application/octet-stream",
                           checksum: "7617bbb06b191eac363b108295d1dd9e",
                           tmp_token: "a86e05200b4ee302f836c84e07c94ad6",
                           accepted: nil,
                           publication_id: @publication.id)
        expect(ad.is_viewable? "").to be_falsey
      end  
    end
    context "when asset is embargoed" do
      it "should return false" do
        ad = AssetData.create(name: "Test file",
                           content_type: "application/octet-stream",
                           checksum: "7617bbb06b191eac363b108295d1dd9e",
                           tmp_token: "a86e05200b4ee302f836c84e07c94ad6",
                           accepted: "2016-10-01",
                           visible_after: DateTime.now + 10,
                           publication_id: @publication.id)
        expect(ad.is_viewable? "").to be_falsey
      end  
    end

  end

end

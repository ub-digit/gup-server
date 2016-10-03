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

end

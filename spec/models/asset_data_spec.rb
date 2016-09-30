require 'rails_helper'

RSpec.describe AssetData, :type => :model do
  
  before :each do
    create(:publication, id: 1)
    @upload_root = "var/tmp/gup_asset"
    @publication = Publication.find(1)
  end
  
  it "should save a complete file post" do
    ad = AssetData.new(name: "Test file", 
                       path: "/tmp",
                       accepted: false,
                       publication_id: @publication.id)
    expect(ad.save).to be_truthy
  end
  
  it "should require publication" do
    ad = AssetData.new(name: "Test file", 
                       path: "/tmp",
                       accepted: false)
    expect(ad.save).to be_falsey
  end

  it "should require name" do
    ad = AssetData.new(path: "/tmp",
                       accepted: false,
                       publication_id: @publication.id)
    expect(ad.save).to be_falsey
  end

  it "should require accepted" do
    ad = AssetData.new(path: "/tmp",
                       publication_id: @publication.id)
    expect(ad.save).to be_falsey
  end
end
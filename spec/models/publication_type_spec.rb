require 'rails_helper'

RSpec.describe PublicationType, :type => :model do
  it "should create a new publication type" do
    p = PublicationType.new label: "dummylabel", publication_type_code:"dummy"
    expect(p.save).to be_truthy
  end
  it "must not create a duplicate publication type" do
    create(:publication_type, publication_type_code: "article", content_type:"ref")
    p = PublicationType.new publication_type_code:"article", content_type:"ref"
    expect(p.save).to be_falsey
  end
  it "requires field 'publication_type_code'" do
    p = PublicationType.new
    expect(p.save).to be_falsey
  end
end

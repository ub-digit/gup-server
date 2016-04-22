require 'rails_helper'

RSpec.describe PublicationVersion, type: :model do
  describe "publication type field " do
    context "unpublished publication" do
      it "does not need publication type" do
        p = build(:publication_version, publication: create(:draft_publication), publication_type: nil)
        expect(p.save).to be_truthy
      end
    end
    context "published publication" do 
      it "needs publication type" do 
        p = build(:publication_version, publication: create(:publication), publication_type: nil)
        expect(p.save).to be_falsey
      end
    end
  end

  describe "title field" do
    context "unpublished publication" do
      it "does not title" do
        p = build(:publication_version, publication: create(:draft_publication), title: nil) 
        expect(p.save).to be_truthy
      end
    end
    context "published publication" do
      it "needs title" do
        p = build(:publication_version, publication: create(:publication), title: nil) 
        expect(p.save).to be_falsey
      end
    end
  end

  describe "pubyear field" do
    context "unpublished publication" do
      it "does not need pubyear" do
        p = build(:publication_version, publication: create(:draft_publication), pubyear: nil) 
        expect(p.save).to be_truthy
      end
    end
    context "published publication" do
      it "needs pubyear" do
        p = build(:publication_version, publication: create(:publication), pubyear: nil) 
        expect(p.save).to be_falsey
      end        
      it "needs pubyear to be positive integer within reasonable limits" do
        p = build(:publication_version, publication: create(:publication), pubyear: 201) 
        expect(p.save).to be_falsey

        p = build(:publication_version, publication: create(:publication), pubyear: -1) 
        expect(p.save).to be_falsey

        p = build(:publication_version, publication: create(:publication), pubyear: "aa") 
        expect(p.save).to be_falsey
      end
    end
  end  

  describe "sourcetitle field" do
    context "unpublished publication" do
      it "does not need sourcetitle" do
        p = build(:publication_version, publication: create(:draft_publication), sourcetitle: nil) 
        expect(p.save).to be_truthy
      end
    end
    context "for publication type journal-articles" do 
      it "needs sourcetitle" do
        p = build(:publication_version, publication: create(:publication), publication_type: "journal-articles", sourcetitle: nil) 
        expect(p.save).to be_falsey
      end
    end
  end


  describe "creating with no-existing fields" do
    it "should throw errror" do
      expect {
        Publication.new is_draft: false, 
                        is_deleted: false, 
                        pubid: 12345,
                        publication_type: 'journal-articles', 
                        dummy: "Dummy", 
                        title:"Test-title", 
                        abstract:"This is an abstract...", 
                        pubyear:201
      }.to raise_error(ActiveRecord::UnknownAttributeError)

    end
  end
end

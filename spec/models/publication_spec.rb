require 'rails_helper'

RSpec.describe Publication, type: :model do
  require 'rails_helper'

  before :each do
    create(:publication_type, form_template: 'article-pop')
    create(:publication_type, form_template: 'article-ref')
    create(:publication_type, form_template: 'none')
  end

  describe "new" do
    describe "when publication is a draft" do
      it "needs pubid" do
        p = Publication.new is_draft: true, is_deleted: true, title:"Test-title", author:"Bengt Sändh", pubyear:2014, abstract:"This is an abstract..."
        expect(p.save).to be_falsey
      end

      it "does not need publication type" do
        p = Publication.new is_draft: true, is_deleted: true, pubid: 12345, title:"Test-title", author:"Bengt Sändh", pubyear:2014, abstract:"This is an abstract..."
        expect(p.save).to be_truthy
      end

      context "for any publication type" do
        it "should create a new publication" do
          p = Publication.new is_draft: true, is_deleted: true, pubid: 12345, publication_type_id: PublicationType.find_by_form_template('article-pop').id, title:"Test-title", author:"Bengt Sändh", pubyear:2014, abstract:"This is an abstract..."
          expect(p.save).to be_truthy
        end
        it "does not need title" do
          p = Publication.new is_draft: true, is_deleted: true, pubid: 12345, publication_type_id: PublicationType.find_by_form_template('article-pop').id, author:"Bengt Sändh", pubyear:2014, abstract:"This is an abstract..."
          expect(p.save).to be_truthy
        end
        it "does not need author" do
          p = Publication.new is_draft: true, is_deleted: true, pubid: 12345, publication_type_id: PublicationType.find_by_form_template('article-pop').id, title:"Test-title", pubyear:2014, abstract:"This is an abstract..."
          expect(p.save).to be_truthy
        end
        it "does not need pubyear" do
          p = Publication.new is_draft: true, is_deleted: true, pubid: 12345, publication_type_id: PublicationType.find_by_form_template('article-pop').id, title:"Test-title", author:"Bengt Sändh", abstract:"This is an abstract..."
          expect(p.save).to be_truthy
        end
      end
    end
    describe "when publication is not a draft" do
      context "publication type is 'none'" do
        it "needs publication type to be other than 'none'" do
          p = Publication.new is_draft: false, is_deleted: false, pubid: 12345, publication_type_id: PublicationType.find_by_form_template('none').id,  title:"Test-title", author:"Bengt Sändh", pubyear:2014, abstract:"This is an abstract..."
          expect(p.save).to be_falsey
        end
      end
      it "needs pubid" do
        p = Publication.new is_draft: true, is_deleted: true, title:"Test-title", author:"Bengt Sändh", pubyear:2014, abstract:"This is an abstract..."
        expect(p.save).to be_falsey
      end

      it "needs publication type" do
        p = Publication.new is_draft: false, is_deleted: true, pubid: 12345, title:"Test-title", author:"Bengt Sändh", pubyear:2014, abstract:"This is an abstract..."
        expect(p.save).to be_falsey
      end

      context "for any publication type" do
        it "should create a new publication" do
          p = Publication.new is_draft: false, is_deleted: true, pubid: 12345, publication_type_id: PublicationType.find_by_form_template('article-pop').id, title:"Test-title", author:"Bengt Sändh", pubyear:2014, abstract:"This is an abstract..."
          expect(p.save).to be_truthy
        end
        it "needs title" do
          p = Publication.new is_draft: false, is_deleted: true, pubid: 12345, publication_type_id: PublicationType.find_by_form_template('article-pop').id, author:"Bengt Sändh", pubyear:2014, abstract:"This is an abstract..."
          expect(p.save).to be_falsey
        end
        it "needs pubyear" do
          p = Publication.new is_draft: false, is_deleted: true, pubid: 12345, publication_type_id: PublicationType.find_by_form_template('article-pop').id, title:"Test-title", author:"Bengt Sändh", abstract:"This is an abstract..."
          expect(p.save).to be_falsey
        end
        it "needs pubyear to be positive integer within reasonable limits" do
          p = Publication.new is_draft: false, is_deleted: true, pubid: 12345, publication_type_id: PublicationType.find_by_form_template('article-pop').id, title:"Test-title", author:"Bengt Sändh", abstract:"This is an abstract...", pubyear:201
          expect(p.save).to be_falsey
          p = Publication.new is_draft: false, is_deleted: true, pubid: 12345, publication_type_id: PublicationType.find_by_form_template('article-pop').id, title:"Test-title", author:"Bengt Sändh", abstract:"This is an abstract...", pubyear:-1
          expect(p.save).to be_falsey
          p = Publication.new is_draft: false, is_deleted: true, pubid: 12345, publication_type_id: PublicationType.find_by_form_template('article-pop').id, title:"Test-title", author:"Bengt Sändh", abstract:"This is an abstract...", pubyear:"aa"
          expect(p.save).to be_falsey        
        end
        it "should throw errror when trying to create a publication with no-existing fields" do
          expect {
            Publication.new is_draft: false, 
            is_deleted: true, 
            pubid: 12345,
            publication_type_id: PublicationType.find_by_form_template('article-pop').id, 
            dummy: "Dummy", 
            title:"Test-title", 
            author:"Bengt Sändh", 
            abstract:"This is an abstract...", 
            pubyear:201
            }.to raise_error(ActiveRecord::UnknownAttributeError)

          end
        end

        context "for publication type: article, ref" do
          it "should create a new publication" do
            p = Publication.new is_draft: false, is_deleted: true, pubid: 12345, publication_type_id: PublicationType.find_by_form_template('article-ref').id, title:"Test-title", author:"Bengt Sändh", sourcetitle:"Test sourcetitle", pubyear:2014, abstract:"This is an abstract..."
            expect(p.save).to be_truthy
          end
          it "needs journal" do
            p = Publication.new is_draft: false, is_deleted: true, pubid: 12345, publication_type_id: PublicationType.find_by_form_template('article-ref').id, title:"Test-title", author:"Bengt Sändh", pubyear:2014, abstract:"This is an abstract..."
            expect(p.save).to be_falsey
          end
        end
      end

      context "for one pubid" do
        it "should not allow 2 active (no deleted) items" do
          p1 = Publication.new is_draft: true, is_deleted: false, pubid: 12345
          expect(p1.save).to be_truthy
          p2 = Publication.new is_draft: true, is_deleted: true, pubid: 12345
          expect(p2.save).to be_truthy
          p3 = Publication.new is_draft: true, is_deleted: false, pubid: 12345
          expect(p3.save).to be_falsey
        end
      end
      it "should allow saving an active item when deleted items already exist" do
        p2 = Publication.new is_draft: true, is_deleted: true, pubid: 12345
        expect(p2.save).to be_truthy
        p3 = Publication.new is_draft: true, is_deleted: true, pubid: 12345
        expect(p3.save).to be_truthy
        p4 = Publication.new is_draft: true, is_deleted: false, pubid: 12345
        expect(p4.save).to be_truthy
      end
    end
  end


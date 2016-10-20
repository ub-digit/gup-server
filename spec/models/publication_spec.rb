require 'rails_helper'

RSpec.describe Publication, type: :model do

  # RELATIONS
  describe "relations" do
    it {should have_many(:publication_versions)}
    it {should have_many(:postpone_dates)}
    it {should belong_to(:current_version)}
  end

  # VALIDATIONS

  # METHODS
  describe "is_draft?" do
    context "for a published publication" do
      it "should return false" do
        publication = build(:published_publication)

        expect(publication.is_draft?).to be false
      end
    end
    context "for a predraft publication" do
      it "should return false" do
        publication = build(:predraft_publication)

        expect(publication.is_draft?).to be false
      end
    end
    context "for a draft publication" do
      it "should return true" do
        publication = build(:draft_publication)

        expect(publication.is_draft?).to be true
      end
    end
  end

  describe "is_predraft?" do
    context "for a published publication" do
      it "should return false" do
        publication = build(:published_publication)

        expect(publication.is_predraft?).to be false
      end
    end
    context "for a predraft publication" do
      it "should return true" do
        publication = build(:predraft_publication)

        expect(publication.is_predraft?).to be true
      end
    end
    context "for a draft publication" do
      it "should return false" do
        publication = build(:draft_publication)

        expect(publication.is_predraft?).to be false
      end
    end
  end

  describe "is_published?" do
    context "for a published publication" do
      it "should return true" do
        publication = build(:published_publication)

        expect(publication.is_published?).to be true
      end
    end
    context "for a predraft publication" do
      it "should return false" do
        publication = build(:predraft_publication)

        expect(publication.is_published?).to be false
      end
    end
    context "for a draft publication" do
      it "should return false" do
        publication = build(:draft_publication)

        expect(publication.is_predraft?).to be false
      end
    end
  end


  describe "as_json" do
    context "without options" do
      it "should return a hash including current version" do
        publication = create(:publication)

        json = publication.as_json

        expect(json[:version_id]).to eq publication.current_version.id
        expect(json['id']).to eq publication.id
      end
    end
    context "with a version given as option version" do
      it "should return a hash including given version" do
        publication = create(:publication)
        pv2 = create(:publication_version, publication: publication)

        json = publication.as_json({version: pv2})

        expect(json[:version_id]).to eq pv2.id
        expect(json['id']).to eq publication.id
      end
    end
  end

  describe "attributes_indifferent" do
    context "when asking for id as a symbol" do
      it "should return the id" do
        publication = create(:publication)

        result = publication.attributes_indifferent

        expect(result[:id]).to eq publication.id
        expect(result['id']).to eq publication.id
      end
    end
  end

  describe "biblreview_postponed_until" do
    context "when no postpone date exists" do
      it "should return nil" do
        publication = create(:publication)

        result = publication.biblreview_postponed_until

        expect(result).to be nil
      end
    end
    context "when a postpone date exists" do
      it "should return the postpone date" do
        publication = create(:publication)
        postpone_date = create(:postponed_postpone_date, publication: publication)

        result = publication.biblreview_postponed_until

        expect(result).to be_a ActiveSupport::TimeWithZone
      end
    end
  end

  describe "build_new" do
    it "should build a new publication with given params" do
      publication = Publication.build_new({title: "NewTitle"})
      
      expect(publication.current_version.title).to eq "NewTitle"
    end
  end

  describe "set_postponed_until" do
    context "with no previous postpone date objects" do
      it "should return true" do
        publication = create(:published_publication)
        
        result = publication.set_postponed_until(postponed_until: DateTime.now+1, postponed_by: 'me')

        expect(result).to be true
      end
    end
    context "with an epub ahead of print flag set" do
      it "should return true" do
        publication = create(:publication)

        result = publication.set_postponed_until(postponed_until: DateTime.now+1, postponed_by: 'me', epub_ahead_of_print: true)

        expect(result).to be true
      end
    end
    context "with a previous postpone date object" do
      it "should return true" do
        publication = create(:publication)
        postpone_date = create(:postpone_date, publication: publication)

        result = publication.set_postponed_until(postponed_until: DateTime.now+1, postponed_by: 'me', epub_ahead_of_print: true)

        expect(result).to be true
      end
    end
  end
end

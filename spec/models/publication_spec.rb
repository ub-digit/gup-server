require 'rails_helper'

RSpec.describe Publication, type: :model do

  # RELATIONS
  describe "relations" do
    it {should have_many(:publication_versions)}
    it {should have_many(:postpone_dates)}
    it {should belong_to(:current_version)}
    it {should have_one(:endnote_record)}
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

  describe "has_duplicates?" do
    context "for a publication with duplicate identifiers" do
      it "should return true" do
        pub = create(:published_publication)
        pid1 = create(:publication_identifier, publication_version_id: pub.current_version_id, identifier_code: 'doi', identifier_value: :pid_value_1)
        pid2 = create(:publication_identifier, publication_version_id: pub.current_version_id, identifier_code: 'doi', identifier_value: :pid_value_2)

        publication_identifiers = []
        publication_identifiers << pid1
        publication_identifiers << pid2
        duplicates = Publication.has_duplicates?(publication_identifiers)
        expect(duplicates).to be_truthy
      end
    end

    context "for a publication with no duplicate identifiers" do
      it "should return false" do
        pub1 = create(:publication)

        publication_identifiers = []
        duplicates = Publication.has_duplicates?(publication_identifiers)
        expect(duplicates).to be_falsey
      end
    end
  end

  describe "process_state" do
    context "for a published publication" do
      it "should return PUBLISHED" do
        publication = create(:published_publication)

        #expect(Publication.process_state(publication.id)).to be "PUBLISHED"
        expect(publication.current_process_state).to eq "PUBLISHED"
      end
    end
    context "for a predraft publication" do
      it "should return PREDRAFT" do
        publication = build(:predraft_publication)

        #expect(Publication.process_state(publication.id)).to be "PREDRAFT"
        expect(publication.current_process_state).to eq "PREDRAFT"
      end
    end
    context "for a draft publication" do
      it "should return DRAFT" do
        publication = build(:draft_publication)

        #expect(Publication.process_state(publication.id)).to be "DRAFT"
        expect(publication.current_process_state).to eq "DRAFT"
      end
    end
  end

  describe "duplicates" do
    context "when there is a published publication" do
      context "with a duplicate identifier" do
        it "should return duplicate objects" do
          pub = create(:published_publication)
          pid1 = create(:publication_identifier, publication_version_id: pub.current_version_id, identifier_code: 'doi', identifier_value: '99999999')
          pid2 = create(:publication_identifier, publication_version_id: pub.current_version_id, identifier_code: 'doi', identifier_value: '88888888')

          publication_identifiers = []
          publication_identifiers << {identifier_code: 'doi', identifier_value: '99999999'}
          publication_identifiers << {identifier_code: 'doi', identifier_value: '88888888'}
          duplicates = Publication.duplicates(publication_identifiers)
          expect(duplicates.count).to eq 1
        end
      end
      context "with the duplicate identifier in different case" do
        it "should return duplicate objects" do
          pub = create(:published_publication)
          pid1 = create(:publication_identifier, publication_version_id: pub.current_version_id, identifier_code: 'doi', identifier_value: '10.1000/xYz123')
          #pid2 = create(:publication_identifier, publication_version_id: pub_a.current_version_id, identifier_code: 'doi', identifier_value: '88888888')

          publication_identifiers = []
          publication_identifiers << {identifier_code: 'doI', identifier_value: '10.1000/Xyz123'}
          #publication_identifiers << {identifier_code: 'doi', identifier_value: '10.1000/xyz123'}
          duplicates = Publication.duplicates(publication_identifiers)
          expect(duplicates.count).to eq 1
        end
      end
    end

    context "when there is a draft publication" do
      context "with a duplicate identifier" do
        it "should not return duplicate objects" do
          pub = create(:draft_publication)
          pid3 = create(:publication_identifier, publication_version_id: pub.current_version_id, identifier_code: 'doi', identifier_value: '99999999')
          pid4 = create(:publication_identifier, publication_version_id: pub.current_version_id, identifier_code: 'doi', identifier_value: '88888888')

          publication_identifiers = []
          publication_identifiers << {identifier_code: 'doi', identifier_value: '99999999'}
          publication_identifiers << {identifier_code: 'doi', identifier_value: '88888888'}
          duplicates = Publication.duplicates(publication_identifiers)
          expect(duplicates.count).to eq 0
        end
      end
      context "with the duplicate identifier in different case" do
        it "should not return duplicate objects" do
          pub = create(:draft_publication)
          pid3 = create(:publication_identifier, publication_version_id: pub.current_version_id, identifier_code: 'doi', identifier_value: '10.1000/xYz123')
          #pid4 = create(:publication_identifier, publication_version_id: pub_b.current_version_id, identifier_code: 'doi', identifier_value: '88888888')

          publication_identifiers = []
          publication_identifiers << {identifier_code: 'doi', identifier_value: '10.1000/xyz123'}
          #publication_identifiers << {identifier_code: 'doi', identifier_value: '10.1000/xyz123'}
          duplicates = Publication.duplicates(publication_identifiers)
          expect(duplicates.count).to eq 0
        end
      end
    end
  end

end

require 'rails_helper'

RSpec.describe V1::PostponeDatesController, type: :controller do
  describe "create" do 
    context "with no admin rights" do
      it "should return an error message" do
        create(:publication, id: 45687)
        
        post :create, postpone_date: { publication_id: 45687, postponed_until: '2030-01-01' } , api_key: @api_key

        expect(json["error"]).to_not be nil
      end
    end

    context "with invalid pubid and admin rights" do
      it "should return an error message" do
        post :create, postpone_date: { publication_id: 9999999, postponed_until: '2030-01-01' }, api_key: @api_admin_key

        expect(json["error"]).to_not be nil
      end
    end

    context "for a draft publication and admin rights" do
      it "should return an error message" do
        create(:draft_publication, id: 45687)

        post :create, postpone_date: { publication_id: 45687, postponed_until: '2030-01-01' }, api_key: @api_admin_key

        expect(json["error"]).to_not be nil
      end
    end


    context "invalid input params and admin rights" do
      it "should return an error message" do
        create(:published_publication, id: 45687)

        post :create, postpone_date: { publication_id: 45687, postponed_until: '' }, api_key: @api_admin_key

        expect(json["error"]).to_not be nil
      end
    end

    context "for a valid pubid, valid publication state and admin rights" do
      it "should return a success message" do
        create(:published_publication, id: 45687)
        post :create, postpone_date: { publication_id: 45687, postponed_until: '2030-01-01' }, api_key: @api_admin_key

        expect(json["error"]).to be nil
        expect(json["postpone_date"]).to_not be nil
      end
    end

    context "for a valid pubid, with epub ahead of print as comment" do
      it "should set epub_ahead_of_print flag to current DateTime" do
        publication = create(:published_publication, id: 45687)
          
        post :create, postpone_date: { publication_id: 45687, postponed_until: '2030-01-01', comment: 'E-pub ahead of print' }, api_key: @api_admin_key

        publication.reload

        expect(publication.epub_ahead_of_print).to_not be nil
      end
    end

    context "for a valid pubid, with something other than epub ahead of print as comment" do
      it "should not set epub_ahead_of_print flag" do
        publication = create(:published_publication, id: 45687)
          
        post :create, postpone_date: { publication_id: 45687, postponed_until: '2030-01-01', comment: 'E-pub ahead of sprint' }, api_key: @api_admin_key
        publication.reload

        expect(publication.epub_ahead_of_print).to be nil
      end
    end

    context "with no postpone data provided" do
      it "should return a no data error" do
        post :create, api_key: @api_admin_key

        expect(json['error']).to_not be nil
      end
    end
  end
end

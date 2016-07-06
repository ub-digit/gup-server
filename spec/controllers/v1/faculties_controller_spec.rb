require 'rails_helper'

RSpec.describe V1::FacultiesController, type: :controller do
  describe "index" do
    context "for existing faculties" do
      it "should return a list of faculties" do    
        create_list(:faculty, 10)

        get :index, api_key: @api_key
      
        expect(json["faculties"]).to_not be nil
        expect(json["faculties"]).to be_an(Array)
        expect(json["faculties"].count).to eq 10
      end
      context "for locale sv" do
        it "should return a list of faculties ordered by name_sv" do
          create(:faculty, name_sv: "AAA", name_en: "DDD" )
          create(:faculty, name_sv: "CCC", name_en: "BBB" )

          get :index, locale: 'sv', api_key: @api_key

          expect(json['faculties']).to_not be nil
          expect(json['faculties'][0]['name']).to eq "AAA"
          expect(json['faculties'][1]['name']).to eq "CCC"
        end
      end
      context "for locale en" do
        it "should return a list of faculties ordered by name_en" do
          create(:faculty, name_sv: "AAA", name_en: "DDD" )
          create(:faculty, name_sv: "CCC", name_en: "BBB" )

          get :index, locale: 'en', api_key: @api_key

          expect(json['faculties']).to_not be nil
          expect(json['faculties'][0]['name']).to eq "BBB"
          expect(json['faculties'][1]['name']).to eq "DDD"
        end
      end
    end
    context "for an empty list of faculties" do
      it "should return an empty list" do
        get :index, api_key: @api_key

        expect(json['faculties']).to be_an(Array)
        expect(json['faculties'].count).to eq 0
      end
    end
  end
end

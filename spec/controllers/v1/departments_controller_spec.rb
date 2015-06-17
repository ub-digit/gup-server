require 'rails_helper'

RSpec.describe V1::DepartmentsController, type: :controller do

  describe "index" do
    context "for existing departments" do
      it "should return a list of departments" do
        create_list(:department, 10)

        get :index

        expect(json['departments']).to_not be nil
        expect(json['departments'].count).to eq 10
      end
      context "for locale sv" do
        it "should return a list of departments ordered by name_sv" do
          create(:department, name_sv: "AAA", name_en: "DDD" )
          create(:department, name_sv: "CCC", name_en: "BBB" )

          get :index, locale: 'sv'

          expect(json['departments']).to_not be nil
          expect(json['departments'][0]['name']).to eq "AAA"
          expect(json['departments'][1]['name']).to eq "CCC"
        end
      end
      context "for locale en" do
        it "should return a list of departments ordered by name_en" do
          create(:department, name_sv: "AAA", name_en: "DDD" )
          create(:department, name_sv: "CCC", name_en: "BBB" )

          get :index, locale: 'en'

          expect(json['departments']).to_not be nil
          expect(json['departments'][0]['name']).to eq "BBB"
          expect(json['departments'][1]['name']).to eq "DDD"
        end
      end
      context "for year parameter set" do
        it "should not return department with start year after that year" do
          create(:department, name_sv: "Test", start_year: 2011)

          get :index, year: 2010

          expect(json['departments']).to_not be nil
          expect(json['departments'].each{ |d| d['name_sv'].eql?("Test")}).to eq []
        end
        it "should not return department with end year before that year" do
          create(:department, name_sv: "Test", end_year: 2009)

          get :index, year: 2010

          expect(json['departments']).to_not be nil
          expect(json['departments'].each{ |d| d['name_sv'].eql?("Test")}).to eq []
        end
      end
    end

    context "for an empty list of departments" do
      it "should return an empty list" do
        get :index

        expect(json['departments']).to be_an(Array)
        expect(json['departments'].count).to eq 0
      end
    end
  end
end

require 'rails_helper'

RSpec.describe V1::DepartmentsController, type: :controller do

  describe "index" do
    context "for existing departments" do
      it "should return a list of departments" do
        create_list(:department, 10)

        get :index, api_key: @api_key

        expect(json['departments']).to_not be nil
        expect(json['departments'].count).to eq 10
      end
      context "for locale sv" do
        it "should return a list of departments ordered by name_sv" do
          create(:department, name_sv: "AAA", name_en: "DDD" )
          create(:department, name_sv: "CCC", name_en: "BBB" )

          get :index, locale: 'sv', api_key: @api_key

          expect(json['departments']).to_not be nil
          expect(json['departments'][0]['name']).to eq "AAA"
          expect(json['departments'][1]['name']).to eq "CCC"
        end
      end
      context "for locale en" do
        it "should return a list of departments ordered by name_en" do
          create(:department, name_sv: "AAA", name_en: "DDD" )
          create(:department, name_sv: "CCC", name_en: "BBB" )

          get :index, locale: 'en', api_key: @api_key

          expect(json['departments']).to_not be nil
          expect(json['departments'][0]['name']).to eq "BBB"
          expect(json['departments'][1]['name']).to eq "DDD"
        end
      end
      context "for year parameter set" do
        it "should not return department with start year after that year" do
          create(:department, name_sv: "Test", start_year: 2011)

          get :index, year: 2010, api_key: @api_key

          expect(json['departments']).to_not be nil
          expect(json['departments'].each{ |d| d['name_sv'].eql?("Test")}).to eq []
        end
        it "should not return department with end year before that year" do
          create(:department, name_sv: "Test", end_year: 2009)

          get :index, year: 2010, api_key: @api_key

          expect(json['departments']).to_not be nil
          expect(json['departments'].each{ |d| d['name_sv'].eql?("Test")}).to eq []
        end
        it "should return department on edge of year interval" do
          create(:department, name_sv: "Test", start_year: 2000, end_year: 2009)

          get :index, year: 2009, api_key: @api_key

          expect(json['departments']).to_not be nil
          expect(json['departments'][0]).to_not be nil
          expect(json['departments'][0]['name']).to eq "Test"
        end
      end
      context "for search_term provided" do
        it "should list departments matching search term in both swedish and english names" do
          create(:department, name_sv: "Testinst nummer 1", name_en: "Test institution number 1")
          create(:department, name_sv: "Ett riktigt svenskt namn", name_en: "The english name")
          create(:department, name_sv: "Ett annat svenskt namn", name_en: "Another english name")
          create(:department, name_sv: "Detta motsvarar inget som skrivits tidigare",
                 name_en: "This is different from everything else")
          create(:department, name_sv: "Nu skriver vi mer strunt",
                 name_en: "The word namn is not english")

          get :index, search_term: "svenskt", api_key: @api_key
          expect(json['departments']).to_not be nil
          expect(json['departments'].count).to eq(2)
          
          get :index, search_term: "num", api_key: @api_key
          expect(json['departments']).to_not be nil
          expect(json['departments'].count).to eq(1)
          
          get :index, search_term: "namn", api_key: @api_key
          expect(json['departments']).to_not be nil
          expect(json['departments'].count).to eq(3)
        end
      end
    end

    context "for an empty list of departments" do
      it "should return an empty list" do
        get :index, api_key: @api_key

        expect(json['departments']).to be_an(Array)
        expect(json['departments'].count).to eq 0
      end
    end
  end
  
  describe "update" do
    context "with new end year" do
      it "should save when end year is valid" do
        dep = create(:department, name_sv: "Test1", name_en: "Test1", 
                     start_year: 2000, end_year: nil, id: 12)
        
        data = dep.as_json
        data[:end_year] = 2001
        
        put :update, id: 12, department: data, api_key: @api_key
        
        expect(response.status).to eq(200)
        dep2 = Department.find_by_id(12)
        
        expect(dep2.end_year).to eq(2001)
      end

      it "should give error when end year is invalid" do
        dep = create(:department, name_sv: "Test1", name_en: "Test1", 
                     start_year: 2000, end_year: nil, id: 12)
        
        data = dep.as_json
        data[:end_year] = 1990
        
        put :update, id: 12, department: data, api_key: @api_key
        
        expect(response.status).to eq(422)
        dep2 = Department.find_by_id(12)
        
        expect(dep2.end_year).to be nil
      end
    end
  end

  describe "create" do
    context "with valid fields" do
      it "should create and return a department" do
        post :create, department: {name_sv: 'namn', name_en: 'name', start_year: 1879, end_year: 1979}.as_json, api_key: @api_key

        expect(response.status).to eq 201
        expect(json['department']).to_not be nil
        
        dep = Department.find_by_id(json['department']['id'])
        expect(dep).to_not be nil
      end
    end
    context "with invalid fields" do
      it "should return an error message upon department creation failure" do
        post :create, department: {name_sv: nil, name_en: 'name', start_year: 1879, end_year: 1979}.as_json, api_key: @api_key

        expect(response.status).to eq 422

      end
    end
  end
end

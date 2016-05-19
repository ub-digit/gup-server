# coding: utf-8
require 'rails_helper'

RSpec.describe V1::ReportsController, type: :controller do
  describe "create" do
    before :each do
      @years = [2005, 2010, 2010, 2010, 2010, 2005, 2006, 2015, 2012, 2012]
      @pubtypes = ['journal-articles', 'journal-articles', 'journal-articles', 'books', 'books',
                   'poster', 'book-review', 'magazine-articles', 'edited-book', 'patent']
      @contenttypes = ['ref', 'ref', 'ref', 'pop', 'pop', 'ref', 'ref', 'vet', 'vet', 'vet']
      
      @faculty_1 = 1000
      @faculty_2 = 1001
      @faculty_3 = 1002

      @dep_1 = create(:department, id: 1, faculty_id: @faculty_1)
      @dep_2 = create(:department, id: 2, faculty_id: @faculty_2)
      @dep_3 = create(:department, id: 3, faculty_id: @faculty_3)
      @dep_4 = create(:department, id: 4, faculty_id: @faculty_1)
      @dep_5 = create(:department, id: 5, faculty_id: @faculty_2)

      @person_a = create(:xkonto_person)
      @person_b = create(:xkonto_person)
      @person_c = create(:xkonto_person2)
      
      @affiliations = [
        { person: create(:person), department: @dep_1 },
        { person: create(:person), department: @dep_1 },
        { person: create(:person), department: @dep_1 },
        { person: @person_a, department: @dep_4 },
        { person: @person_b, department: @dep_2 },
        { person: create(:person), department: @dep_5 },
        { person: create(:person), department: @dep_4 },
        { person: create(:person), department: @dep_4 },
        { person: create(:person), department: @dep_2 },
        { person: @person_c, department: @dep_3 },
      ]
      
      @publications = create_list(:publication, 10)
      
      # Set data related to the version
      @publications.each.with_index do |pub,i| 
        # Set pubyear
        pub.current_version.update_attribute(:pubyear, @years[i])
        
        # Set pubtype
        pub.current_version.update_attribute(:publication_type, @pubtypes[i])

        # Set content type
        pub.current_version.update_attribute(:content_type, @contenttypes[i])
      end

      # Add a draft to catch that only published publications should be counted
      @draft = create(:draft_publication)
      @draft.current_version.update_attribute(:pubyear, 2010)
      tmp = create(:people2publication, 
                   person: @person_b,
                   publication_version: @draft.current_version)
      create(:departments2people2publication,
             department: @dep_3,
             people2publication: tmp)
      
      # Generate affilations
      @affiliations.each.with_index do |aff,i| 
        tmp = create(:people2publication, 
                     person: aff[:person],
                     publication_version: @publications[i].current_version)
        create(:departments2people2publication,
               department: aff[:department],
               people2publication: tmp)
      end
      
      # Need one item with multiple people affiliated
      tmp = create(:people2publication, 
                   person: @person_c,
                   publication_version: @publications[-1].current_version)
      create(:departments2people2publication,
             department: @dep_3,
             people2publication: tmp)
    end
    context "reports" do
      context "complete sum" do
        it "should return a report with the number of publications" do
          post :create, report: { }, api_key: @api_key
          expect(json['error']).to be nil
          expect(json['report']).to_not be nil
          expect(json['report']['data']).to_not be nil
          expect(json['report']['data']).to be_an(Array)
          expect(json['report']['columns']).to_not be nil
          expect(json['report']['columns'][0]).to eq('Antal')
          expect(json['report']['data'][0][0]).to eq(10)
        end
      end
      
      context "filtered by pubyear" do
        it "should return count only for requested year range" do
          post :create, report: { filter: {start_year: 2010, end_year: 2012}, }, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['columns'][0]).to eq('Antal')
          expect(json['report']['data'][0][0]).to eq(6)
        end

        it "should return count only for requested year range with only one year" do
          post :create, report: { filter: {start_year: 2010, end_year: 2010}, }, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['columns'][0]).to eq('Antal')
          expect(json['report']['data'][0][0]).to eq(4)
        end

        it "should return count only for requested year range with only start_year" do
          post :create, report: { filter: {start_year: 2011}, }, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['columns'][0]).to eq('Antal')
          expect(json['report']['data'][0][0]).to eq(3)
        end

        it "should return count only for requested year range with only end_year" do
          post :create, report: { filter: {end_year: 2010}, }, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['columns'][0]).to eq('Antal')
          expect(json['report']['data'][0][0]).to eq(7)
        end
      end
      
      context "filtered by publication type" do
        it "should return count only for requested single pub type" do
          post :create, report: { filter: {publication_types: ['journal-articles']}, }, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['columns'][0]).to eq('Antal')
          expect(json['report']['data'][0][0]).to eq(3)
        end

        it "should return count only for requested multiple pub types" do
          post :create, report: { filter: {publication_types: ['journal-articles', 'books']}, }, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['columns'][0]).to eq('Antal')
          expect(json['report']['data'][0][0]).to eq(5)
        end
      end
      
      context "filtered by content type" do
        it "should return count only for requested single content type" do
          post :create, report: { filter: {content_types: ['pop']}, }, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['columns'][0]).to eq('Antal')
          expect(json['report']['data'][0][0]).to eq(2)
        end

        it "should return count only for requested multiple pub types" do
          post :create, report: { filter: {content_types: ['ref', 'pop']}, }, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['columns'][0]).to eq('Antal')
          expect(json['report']['data'][0][0]).to eq(7)
        end
      end
      
      context "filtered by faculty" do
        it "should return count only for selected faculty" do
          post :create, report: { filter: {faculties: [@faculty_1]}, }, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['columns'][0]).to eq('Antal')
          expect(json['report']['data'][0][0]).to eq(6)
        end
      end

      context "filtered by department" do
        it "should return count only for selected department" do
          post :create, report: { filter: {departments: [@dep_4.id]}, }, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['columns'][0]).to eq('Antal')
          expect(json['report']['data'][0][0]).to eq(3)
        end
      end

      context "filtered by person" do
        it "should return count only for selected person" do
          identifier = @person_a.identifiers.where(source: Source.find_by_name("xkonto")).first
          xaccount = identifier.value
          post :create, report: { filter: {persons: [xaccount]}, }, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['columns'][0]).to eq('Antal')
          expect(json['report']['data'][0][0]).to eq(2)
        end
      end
      
      context "without filter" do
        context "grouped by year" do
          it "should return matrix with count per year" do
            post :create, report: { columns: [:year], }, api_key: @api_key
            expect(json['report']).to_not be nil
            expect(json['report']['columns'][0]).to eq('År')
            expect(json['report']['columns'][1]).to eq('Antal')
            expect(json['report']['data'].size).to eq(5)
            expect(json['report']['data'][0][0]).to eq(2005)
            expect(json['report']['data'][1][0]).to eq(2006)
            expect(json['report']['data'][0][1]).to eq(2)
            expect(json['report']['data'][1][1]).to eq(1)
          end
        end

        context "grouped by publication type and year" do
          it "should return matrix with count per publication_type and year" do
            post :create, report: { columns: [:year, :publication_type], }, api_key: @api_key
            expect(json['report']).to_not be nil
            expect(json['report']['columns'][0]).to eq('År')
            expect(json['report']['columns'][1]).to eq('Publikationstyp')
            expect(json['report']['columns'][2]).to eq('Antal')
            expect(json['report']['data'].size).to eq(8)
            expect(json['report']['data'][0][0]).to eq(2005)
            expect(json['report']['data'][5][0]).to eq(2012)
            expect(json['report']['data'][0][1]).to eq("Artikel i vetenskaplig tidskrift")
            expect(json['report']['data'][5][1]).to eq("edited-book")
            expect(json['report']['data'][0][2]).to eq(1)
            expect(json['report']['data'][5][2]).to eq(1)
          end
        end
      end
      
      context "with filter" do
        context "grouped by year for specific publication type" do
          it "should return matrix with count per year" do
            post :create, report: { filter: {publication_types: ['journal-articles', 'books']}, columns: [:year], }, api_key: @api_key
            expect(json['report']).to_not be nil
            expect(json['report']['columns'][0]).to eq('År')
            expect(json['report']['columns'][1]).to eq('Antal')
            expect(json['report']['data'].size).to eq(2)
            expect(json['report']['data'][0][0]).to eq(2005)
            expect(json['report']['data'][1][0]).to eq(2010)
            expect(json['report']['data'][0][1]).to eq(1)
            expect(json['report']['data'][1][1]).to eq(4)
          end
        end

        context "grouped by publication type and year and filter on year range" do
          it "should return matrix with count per publication_type and year filtered by certain years" do
            post :create, report: { filter: {start_year: 2010, end_year: 2015}, columns: [:year, :publication_type], }, api_key: @api_key
            expect(json['report']).to_not be nil
            expect(json['report']['columns'][0]).to eq('År')
            expect(json['report']['columns'][1]).to eq('Publikationstyp')
            expect(json['report']['columns'][2]).to eq('Antal')
            expect(json['report']['data'].size).to eq(5)
            expect(json['report']['data'][0][0]).to eq(2010)
            expect(json['report']['data'][4][0]).to eq(2015)
            expect(json['report']['data'][0][1]).to eq("books")
            expect(json['report']['data'][4][1]).to eq("Artikel i övriga tidskrifter")
            expect(json['report']['data'][0][2]).to eq(2)
            expect(json['report']['data'][4][2]).to eq(1)
          end
        end
      end
      
      context "export csv" do
        it "should return the report data in csv format when requested" do
          get :show, name: "testreport", report: { filter: {start_year: 2010, end_year: 2015}, columns: [:year, :publication_type], }, api_key: @api_key
          expected_result = "År\tPublikationstyp\tAntal\n2010\tbooks\t2\n2010\tArtikel i vetenskaplig tidskrift\t2\n2012\tedited-book\t1\n2012\tpatent\t1\n2015\tArtikel i övriga tidskrifter\t1"
          expect(response.body).to eq(expected_result)
        end
      end
    end
  end
end

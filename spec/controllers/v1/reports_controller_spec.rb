require 'rails_helper'

RSpec.describe V1::ReportsController, type: :controller do
  describe "create" do
    before :each do
      @years = [2005, 2010, 2010, 2010, 2010, 2005, 2006, 2015, 2012, 2012]
      @pubtypes = ['journal-articles', 'journal-articles', 'journal-articles', 'books', 'books',
                   'poster', 'book-review', 'magazine-articles', 'edited-book', 'patent']
      
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
        { person: @person_a, department: @dep_3 },
      ]
      
      @publications = create_list(:publication, 10)
      
      # Set data related to the version
      @publications.each.with_index do |pub,i| 
        # Set pubyear
        pub.current_version.update_attribute(:pubyear, @years[i])
        
        # Set pubtype
        pub.current_version.update_attribute(:publication_type, @pubtypes[i])
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
                   person: @person_b,
                   publication_version: @publications[-1].current_version)
      create(:departments2people2publication,
             department: @dep_3,
             people2publication: tmp)
    end
    context "reports" do
      context "complete sum" do
        it "should return a report with the number of publications" do
          post :create, api_key: @api_key
          expect(json['error']).to be nil
          expect(json['report']).to_not be nil
          expect(json['report']['data']).to_not be nil
          expect(json['report']['data']).to be_an(Array)
          expect(json['report']['columns']).to_not be nil
          expect(json['report']['columns'][0]).to eq('count')
          expect(json['report']['data'][0][0]).to eq(10)
        end
      end
      
      context "filtered by pubyear" do
        it "should return count only for requested year range" do
          post :create, filter: {start_year: 2010, end_year: 2012}, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['columns'][0]).to eq('count')
          expect(json['report']['data'][0][0]).to eq(6)
        end

        it "should return count only for requested year range with only one year" do
          post :create, filter: {start_year: 2010, end_year: 2010}, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['columns'][0]).to eq('count')
          expect(json['report']['data'][0][0]).to eq(4)
        end

        it "should return count only for requested year range with only start_year" do
          post :create, filter: {start_year: 2011}, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['columns'][0]).to eq('count')
          expect(json['report']['data'][0][0]).to eq(3)
        end

        it "should return count only for requested year range with only end_year" do
          post :create, filter: {end_year: 2010}, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['columns'][0]).to eq('count')
          expect(json['report']['data'][0][0]).to eq(7)
        end
      end
      
      context "filtered by publication type" do
        it "should return count only for requested single pub type" do
          post :create, filter: {publication_types: ['journal-articles']}, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['columns'][0]).to eq('count')
          expect(json['report']['data'][0][0]).to eq(3)
        end

        it "should return count only for requested multiple pub types" do
          post :create, filter: {publication_types: ['journal-articles', 'books']}, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['columns'][0]).to eq('count')
          expect(json['report']['data'][0][0]).to eq(5)
        end
      end
      
      context "filtered by faculty" do
        it "should return count only for selected faculty" do
          post :create, filter: {faculties: [@faculty_1]}, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['columns'][0]).to eq('count')
          expect(json['report']['data'][0][0]).to eq(6)
        end
      end

      context "filtered by department" do
        it "should return count only for selected department" do
          post :create, filter: {departments: [@dep_4.id]}, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['columns'][0]).to eq('count')
          expect(json['report']['data'][0][0]).to eq(3)
        end
      end

      context "filtered by person" do
        it "should return count only for selected person" do
          post :create, filter: {persons: [@person_a.id]}, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['columns'][0]).to eq('count')
          expect(json['report']['data'][0][0]).to eq(2)
        end
      end
      
      context "without filter" do
        context "grouped by year" do
          it "should return matrix with count per year" do
            post :create, columns: [:year], api_key: @api_key
            expect(json['report']).to_not be nil
            expect(json['report']['columns'][0]).to eq('year')
            expect(json['report']['columns'][1]).to eq('count')
            expect(json['report']['data'].size).to eq(5)
            expect(json['report']['data'][0][0]).to eq(2005)
            expect(json['report']['data'][1][0]).to eq(2006)
            expect(json['report']['data'][0][1]).to eq(2)
            expect(json['report']['data'][1][1]).to eq(1)
          end
        end

        context "grouped by publication type and year" do
          it "should return matrix with count per publication_type and year" do
            post :create, columns: [:year, :publication_type], api_key: @api_key
            expect(json['report']).to_not be nil
            expect(json['report']['columns'][0]).to eq('year')
            expect(json['report']['columns'][1]).to eq('publication_type')
            expect(json['report']['columns'][2]).to eq('count')
            expect(json['report']['data'].size).to eq(8)
            expect(json['report']['data'][0][0]).to eq(2005)
            expect(json['report']['data'][5][0]).to eq(2012)
            expect(json['report']['data'][0][1]).to eq("journal-articles")
            expect(json['report']['data'][5][1]).to eq("edited-book")
            expect(json['report']['data'][0][2]).to eq(1)
            expect(json['report']['data'][5][2]).to eq(1)
          end
        end
      end
      
      context "with filter" do
        context "grouped by year for specific publication type" do
          it "should return matrix with count per year" do
            post :create, filter: {publication_types: ['journal-articles', 'books']}, columns: [:year], api_key: @api_key
            expect(json['report']).to_not be nil
            expect(json['report']['columns'][0]).to eq('year')
            expect(json['report']['columns'][1]).to eq('count')
            expect(json['report']['data'].size).to eq(2)
            expect(json['report']['data'][0][0]).to eq(2005)
            expect(json['report']['data'][1][0]).to eq(2010)
            expect(json['report']['data'][0][1]).to eq(1)
            expect(json['report']['data'][1][1]).to eq(4)
          end
        end

        context "grouped by publication type and year and filter on year range" do
          it "should return matrix with count per publication_type and year filtered by certain years" do
            post :create, filter: {start_year: 2010, end_year: 2015}, columns: [:year, :publication_type], api_key: @api_key
            expect(json['report']).to_not be nil
            expect(json['report']['columns'][0]).to eq('year')
            expect(json['report']['columns'][1]).to eq('publication_type')
            expect(json['report']['columns'][2]).to eq('count')
            expect(json['report']['data'].size).to eq(5)
            expect(json['report']['data'][0][0]).to eq(2010)
            expect(json['report']['data'][4][0]).to eq(2015)
            expect(json['report']['data'][0][1]).to eq("books")
            expect(json['report']['data'][4][1]).to eq("magazine-articles")
            expect(json['report']['data'][0][2]).to eq(2)
            expect(json['report']['data'][4][2]).to eq(1)
          end
        end
      end
    end
  end
end

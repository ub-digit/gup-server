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
      
      # Generate affilations
      @affiliations.each.with_index do |aff,i| 
        tmp = create(:people2publication, 
                     person: aff[:person],
                     publication_version: @publications[i].current_version)
        create(:departments2people2publication,
               department: aff[:department],
               people2publication: tmp)
      end
    end
    context "reports" do
      context "complete sum" do
        it "should return a report with the number of publications" do
          post :create, api_key: @api_key
          expect(json['error']).to be nil
          expect(json['report']).to_not be nil
          expect(json['report']['count']).to eq(10)
        end
      end
      
      context "filtered by pubyear" do
        it "should return count only for requested year range" do
          post :create, filter: {start_year: 2010, end_year: 2012}, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['count']).to eq(6)
        end

        it "should return count only for requested year range with only one year" do
          post :create, filter: {start_year: 2010, end_year: 2010}, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['count']).to eq(4)
        end
      end
      
      context "filtered by publication type" do
        it "should return count only for requested single pub type" do
          post :create, filter: {publication_types: ['journal-articles']}, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['count']).to eq(3)
        end

        it "should return count only for requested multiple pub types" do
          post :create, filter: {publication_types: ['journal-articles', 'books']}, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['count']).to eq(5)
        end
      end
      
      context "filtered by faculty" do
        it "should return count only for selected faculty" do
          post :create, filter: {faculty: @faculty_1}, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['count']).to eq(6)
        end
      end

      context "filtered by department" do
        it "should return count only for selected department" do
          post :create, filter: {department: @dep_4.id}, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['count']).to eq(3)
        end
      end

      context "filtered by person" do
        it "should return count only for selected person" do
          post :create, filter: {person: @person_a.id}, api_key: @api_key
          expect(json['report']).to_not be nil
          expect(json['report']['count']).to eq(2)
        end
      end
    end
  end
end

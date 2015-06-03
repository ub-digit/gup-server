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

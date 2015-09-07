require 'rails_helper'

RSpec.describe V1::SourcesController, type: :controller do
  describe "list sources" do

    context "when there are no sources to be found" do
      it "should return an empty sources array" do
        sources = Source.all.each {|source| source.delete}

        get :index, api_key: @api_key

        expect(json['sources'].empty?).to be_truthy
      end
    end

    context "when there is a list of sources to be found" do
      it "should return that list of sources" do
        create_list(:source, 10)

        get :index, api_key: @api_key

        expect(json['sources'].count).to eq 10
      end
    end
  end

  describe "create source" do
    context "when given sufficient parameters" do
      it "should create source and return representation" do
        s1 = Source.new
        s1.name = 'danishjohnnyid'

        post :create, source: {name: s1.name}, api_key: @api_key

        expect(response.status).to eq 201
        expect(json['error']).to be nil
        expect(json['source']).not_to be nil
        expect(json['source']['id']).not_to be nil
        expect(json['source']['name']).to eq(s1.name)
      end
    end

    context "when required parameters are missing" do
      it "should return an error" do
        s1 = Source.new

        post :create, source: {}, api_key: @api_key

        expect(response.status).to eq 422
        expect(json['error']).not_to be nil
        expect(json['source']).to be nil
      end
    end
  end

  describe "retrieve source" do
    context "when the source exist" do
      it "should return that source" do
        source = create(:source)

        get :show, id: source.id, api_key: @api_key

        expect(response.status).to eq(200)
        expect(json['error']).to be nil
        expect(json['source']).not_to be nil
        expect(json['source']['id']).to eq(source.id)
        expect(json['source']['name']).to eq(source.name)
      end
    end
    context "when the source does not exist" do
      it "should return error" do
        get :show, id: 999999999, api_key: @api_key

        expect(response.status).to eq(404)
        expect(json['error']).not_to be nil
        expect(json['source']).to be nil
      end
    end
  end

  describe "update source" do
    context "when properties are changed" do
      it "should update source and return json with new state of the source" do
        source = create(:source)
        new_name = 'xyzkonto'

        post :update, id: source.id, source: {name: new_name}, api_key: @api_key

        expect(response.status).to eq 200
        expect(json['error']).to be nil
        expect(json['source']).not_to be nil
        expect(json['source']['id']).to eq(source.id)
        expect(json['source']['name']).to eq(new_name)
      end
      it "should ignore the created_at param" do
        source = create(:source)
        new_name = 'xyzkonto'
        new_created_at = DateTime.parse('1999-12-31 23:59:59')

        put :update, id: source.id, source: {created_at: new_created_at, name: new_name}, api_key: @api_key

        expect(response.status).to eq 200
        expect(json['error']).to be nil
        expect(json['source']).not_to be nil
        expect((DateTime.parse(json['source']['created_at'])).year).to eq(Time.now().year)
        expect(json['source']['name']).to eq(new_name)
      end
    end

    context "when required property is deleted" do
      it "should return an error" do
        source = create(:source)
        new_name = ''

        put :update, id: source.id, source: {name: new_name}, api_key: @api_key

        expect(response.status).to eq 422
        expect(json['error']).not_to be nil
        expect(json['source']).to be nil
        expect(json['error']['msg']).not_to be nil
      end
    end

    context "when source is not found" do
      it "should return an error" do
        new_name = 'danishjohnnyid'
        new_label = 'Danish Johnny ID'

        put :update, id: 999999999, source: {name: new_name, label: new_label}, api_key: @api_key

        expect(response.status).to eq 404
        expect(json['error']).not_to be nil
        expect(json['source']).to be nil
        expect(json['error']['msg']).not_to be nil
      end
    end
  end

end

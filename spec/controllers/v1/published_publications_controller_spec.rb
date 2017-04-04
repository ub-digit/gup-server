require 'rails_helper'

RSpec.describe V1::PublishedPublicationsController, type: :controller do

  describe "index" do
    before :each do
      @publication = create(:published_publication)
      @publication2 = create(:published_publication)
      publication_version = @publication.current_version

      @person = create(:xkonto_person)
      people2publication = create(:people2publication, publication_version: publication_version, person: @person, position: 1)
      department = create(:department)
      create(:departments2people2publication, people2publication: people2publication, department: department)
    end

    context "for no given actor or registrator" do
      it "should return publications where current user is actor" do

        get :index, api_key: @xtest_key

        expect(response.status).to eq 200
        expect(json['publications'].count).to eq 1
        expect(json['publications'].first['id']).to eq @publication.id
      end
    end

    context "for actor logged_in_user when user has no Person object" do
      it "should return an empty list" do

        get :index, api_key: @api_key

        expect(response.status).to eq 200
        expect(json['error']).to be nil
        expect(json['publications']).to eq []
      end
    end

    context "for actor logged_in_user" do
      it "should return publications where current user is actor" do

        get :index, actor: 'logged_in_user', api_key: @xtest_key

        expect(response.status).to eq 200
        expect(json['publications'].count).to eq 1
        expect(json['publications'].first['id']).to eq @publication.id
      end
    end

    context "for registrator logged_in_user" do
      it "should return publications where current user has created or updated publication" do

        publication_version_2 = @publication2.current_version
        publication_version_2.update_attributes(updated_by: 'xtest')

        get :index, registrator: 'logged_in_user', api_key: @xtest_key

        expect(response.status).to eq 200
        expect(json['publications'].count).to eq 1
        expect(json['publications'].first['id']).to eq @publication2.id
      end
    end

    context "when there are publications different actor objects with the same xaccount" do
      it "should include publications for all actors of the current xaccount in the list" do
        publication3 = create(:published_publication)
        publication4 = create(:published_publication)
        publication_version3 = publication3.current_version
        publication_version4 = publication3.current_version

        person3 = create(:person)
        create(:xkonto_identifier, person: person3, value: 'xtest')

        people2publication = create(:people2publication, publication_version: publication_version3, person: person3)
        department = create(:department)
        create(:departments2people2publication, people2publication: people2publication, department: department)


        person4 = create(:person)
        create(:xkonto_identifier, person: person4, value: 'xother')
        people2publication = create(:people2publication, publication_version: publication_version4, person: person4)
        department = create(:department)
        create(:departments2people2publication, people2publication: people2publication, department: department)

        get :index, api_key: @xtest_key
        expect(json['publications'].count).to eq(2)
        pubids = json['publications'].map { |x| x['id']}
        expect(pubids).to include(publication3.id)
        expect(pubids).to_not include(publication4.id)
      end
    end

    context "for sort order pubyear" do
      it "should return publication list ordered by pubyear desc" do
        publication_version_1 = @publication.current_version
        publication_version_1.update_attributes({title: 'AAA', pubyear: 2000})

        publication3 = create(:published_publication)
        publication_version_3 = publication3.current_version
        publication_version_3.update_attributes({title: 'BBB', pubyear: 2010})
        people2publication3 = create(:people2publication, publication_version: publication_version_3, person: @person)
        department = create(:department)
        create(:departments2people2publication, people2publication: people2publication3, department: department)

        get :index, api_key: @xtest_key, sort_by: 'pubyear'

        expect(response.status).to eq 200
        expect(json['publications'].count).to eq 2
        expect(json['publications'][0]['id']).to eq publication3.id
        expect(json['publications'][1]['id']).to eq @publication.id
      end
    end
    context "for sort order title" do
      it "should return publication list ordered by title asc" do
        publication_version_1 = @publication.current_version
        publication_version_1.update_attributes({title: 'AAA', pubyear: 2010})

        publication3 = create(:published_publication)
        publication_version_3 = publication3.current_version
        publication_version_3.update_attributes({title: 'BBB', pubyear: 2000})
        people2publication3 = create(:people2publication, publication_version: publication_version_3, person: @person)
        department = create(:department)
        create(:departments2people2publication, people2publication: people2publication3, department: department)

        get :index, api_key: @xtest_key, sort_by: 'title'

        expect(response.status).to eq 200
        expect(json['publications'].count).to eq 2
        expect(json['publications'][0]['id']).to eq @publication.id
        expect(json['publications'][1]['id']).to eq publication3.id
      end
    end
    context "for sort order pubtype" do
      it "should return publication list ordered by pubtype label_sv asc" do
        publication_version_1 = @publication.current_version
        publication_type_1 = create(:publication_type, label_sv: "Book")
        publication_version_1.update_attributes({title: 'AAA', pubyear: 2010, publication_type_id: publication_type_1.id})

        publication3 = create(:published_publication)
        publication_version_3 = publication3.current_version
        publication_type_3 = create(:publication_type, label_sv: "Article")
        publication_version_3.update_attributes({title: 'BBB', pubyear: 2000, publication_type_id: publication_type_3.id})
        people2publication3 = create(:people2publication, publication_version: publication_version_3, person: @person)
        department = create(:department)
        create(:departments2people2publication, people2publication: people2publication3, department: department)

        get :index, api_key: @xtest_key, sort_by: 'pubtype'

        expect(response.status).to eq 200
        expect(json['publications'].count).to eq 2
        expect(json['publications'][0]['id']).to eq publication3.id
        expect(json['publications'][1]['id']).to eq @publication.id
      end
    end
    context "for no sort order" do
      it "should return publication list in default sort order (pubyear desc)" do
        publication_version_1 = @publication.current_version
        publication_version_1.update_attributes({title: 'AAA', pubyear: 2010})

        publication3 = create(:published_publication)
        publication_version_3 = publication3.current_version
        publication_version_3.update_attributes({title: 'BBB', pubyear: 2000})
        people2publication3 = create(:people2publication, publication_version: publication_version_3, person: @person)
        department = create(:department)
        create(:departments2people2publication, people2publication: people2publication3, department: department)

        get :index, api_key: @xtest_key

        expect(response.status).to eq 200
        expect(json['publications'].count).to eq 2
        expect(json['publications'][0]['id']).to eq publication3.id
        expect(json['publications'][1]['id']).to eq @publication.id
      end
    end
  end

  describe "index_public" do
    before :each do
      @publication = create(:published_publication)
      publication_version = @publication.current_version

      @person = create(:xkonto_person)
      people2publication = create(:people2publication, publication_version: publication_version, person: @person)
      department = create(:department)
      create(:departments2people2publication, people2publication: people2publication, department: department)
    end
    context "for sort order pubyear" do
      it "should return publication list ordered by pubyear desc" do
        publication_version_1 = @publication.current_version
        publication_version_1.update_attributes({title: 'AAA', pubyear: 2000})

        publication3 = create(:published_publication)
        publication_version_3 = publication3.current_version
        publication_version_3.update_attributes({title: 'BBB', pubyear: 2010})
        people2publication3 = create(:people2publication, publication_version: publication_version_3, person: @person)
        department = create(:department)
        create(:departments2people2publication, people2publication: people2publication3, department: department)

        get :index_public, sort_by: 'pubyear'

        expect(response.status).to eq 200
        expect(json['publications'].count).to eq 2
        expect(json['publications'][0]['id']).to eq publication3.id
        expect(json['publications'][1]['id']).to eq @publication.id
      end
    end
    context "for sort order title" do
      it "should return publication list ordered by title asc" do
        publication_version_1 = @publication.current_version
        publication_version_1.update_attributes({title: 'AAA', pubyear: 2010})

        publication3 = create(:published_publication)
        publication_version_3 = publication3.current_version
        publication_version_3.update_attributes({title: 'BBB', pubyear: 2000})
        people2publication3 = create(:people2publication, publication_version: publication_version_3, person: @person)
        department = create(:department)
        create(:departments2people2publication, people2publication: people2publication3, department: department)

        get :index_public, sort_by: 'title'

        expect(response.status).to eq 200
        expect(json['publications'].count).to eq 2
        expect(json['publications'][0]['id']).to eq @publication.id
        expect(json['publications'][1]['id']).to eq publication3.id
      end
    end
    context "for sort order pubtype" do
      it "should return publication list ordered by pubtype label_sv asc" do
        publication_version_1 = @publication.current_version
        publication_type_1 = create(:publication_type, label_sv: "Book")
        publication_version_1.update_attributes({title: 'AAA', pubyear: 2010, publication_type_id: publication_type_1.id})

        publication3 = create(:published_publication)
        publication_version_3 = publication3.current_version
        publication_type_3 = create(:publication_type, label_sv: "Article")
        publication_version_3.update_attributes({title: 'BBB', pubyear: 2000, publication_type_id: publication_type_3.id})
        people2publication3 = create(:people2publication, publication_version: publication_version_3, person: @person)
        department = create(:department)
        create(:departments2people2publication, people2publication: people2publication3, department: department)

        get :index_public, sort_by: 'pubtype'

        expect(response.status).to eq 200
        expect(json['publications'].count).to eq 2
        expect(json['publications'][0]['id']).to eq publication3.id
        expect(json['publications'][1]['id']).to eq @publication.id
      end
    end
    context "for sort order first_author" do
      it "should return publication list ordered by first_author asc" do
        person_3 = create(:xkonto_person, last_name: 'BBB')
        person_4 = create(:xkonto_person, last_name: 'AAA')
        department = create(:department)

        publication_version_3 = @publication.current_version
        people2publication_3 = create(:people2publication, publication_version: publication_version_3, person: person_3, position: 1)
        create(:departments2people2publication, people2publication: people2publication_3, department: department)

        publication_4 = create(:published_publication)
        publication_version_4 = publication_4.current_version
        people2publication_4 = create(:people2publication, publication_version: publication_version_4, person: person_4, position: 1)
        create(:departments2people2publication, people2publication: people2publication_4, department: department)

        get :index_public, sort_by: 'first_author'

        expect(response.status).to eq 200
        expect(json['publications'].count).to eq 2
        expect(json['publications'][0]['id']).to eq publication_4.id
        expect(json['publications'][1]['id']).to eq @publication.id
      end
    end
    context "for no sort order" do
      it "should return publication list in default sort order (pubyear desc)" do
        publication_version_1 = @publication.current_version
        publication_version_1.update_attributes({title: 'AAA', pubyear: 2010})

        publication3 = create(:published_publication)
        publication_version_3 = publication3.current_version
        publication_version_3.update_attributes({title: 'BBB', pubyear: 2000})
        people2publication3 = create(:people2publication, publication_version: publication_version_3, person: @person)
        department = create(:department)
        create(:departments2people2publication, people2publication: people2publication3, department: department)

        get :index_public

        expect(response.status).to eq 200
        expect(json['publications'].count).to eq 2
        expect(json['publications'][0]['id']).to eq publication3.id
        expect(json['publications'][1]['id']).to eq @publication.id
      end
    end
  end

  describe "create" do
    context "for a predraft publication" do
      context "with valid parameters epub_ahead_of_print set" do
        it "should return publication with epub_ahead_of_print set" do
          create(:predraft_publication, id: 45687)

          post :create, publication: {draft_id: 45687, title: "New test title", epub_ahead_of_print: true}, api_key: @api_key

          expect(json['error']).to be nil
          expect(json["publication"]["epub_ahead_of_print"]).to_not be nil
        end
      end
      context "with valid parameters, epub_ahead_of_print not set" do
        it "should return publication with epub_ahead_of_print not set" do
          create(:predraft_publication, id: 45687)

          post :create, publication: {draft_id: 45687, title: "New test title", epub_ahead_of_print: false}, api_key: @api_key

          expect(json['error']).to be nil
          expect(json["publication"]["epub_ahead_of_print"]).to be nil
        end
      end
      context "based on an endnote import" do
        it "should update the endnote record with the id of the publication" do
          predraft = create(:predraft_publication, id: 45687)
          rec = create(:endnote_article_record)
          predraft.current_version.update_attribute(:sourceid, rec.id)
          predraft.current_version.update_attribute(:datasource, 'endnote')

          post :create, publication: {draft_id: 45687, title: "New test title", epub_ahead_of_print: false}, api_key: @api_key
          rec2 = EndnoteRecord.find_by_id(rec.id)
          expect(rec2.publication_id).to eq predraft.id
        end
      end
    end
    context "for a draft publication" do
      context "with valid parameters" do
        it "should return updated publication" do
          create(:draft_publication, id: 45687)

          post :create, publication: {draft_id: 45687, title: "New test title"}, api_key: @api_key

          expect(json["publication"]).to_not be nil
          expect(json["publication"]).to be_an(Hash)
          expect(json["publication"]["title"]).to eq "New test title"
          expect(json["publication"]["published_at"]).to_not be nil
        end
      end
      context "with valid parameters epub_ahead_of_print set" do
        it "should return publication with epub_ahead_of_print set" do
          create(:draft_publication, id: 45687)

          post :create, publication: {draft_id: 45687, title: "New test title", epub_ahead_of_print: true}, api_key: @api_key

          expect(json['error']).to be nil
          expect(json["publication"]["epub_ahead_of_print"]).to_not be nil
        end
      end
      context "with valid parameters, epub_ahead_of_print not set" do
        it "should return publication with epub_ahead_of_print not set" do
          create(:draft_publication, id: 45687)

          post :create, publication: {draft_id: 45687, title: "New test title", epub_ahead_of_print: false}, api_key: @api_key

          expect(json['error']).to be nil
          expect(json["publication"]["epub_ahead_of_print"]).to be nil
        end
      end

      context "with invalid parameters" do
        it "should return an error message" do
          create(:draft_publication, id: 45687)

          post :create, publication: {draft_id: 45687, publication_type_id: 0, title: "New test title"}, api_key: @api_key

          expect(json["publication"]).to be nil
          expect(json["error"]).to_not be nil
        end
      end
    end
    context "for a non existing draft id" do
      it "should return an error message" do
        post :create, publication: {draft_id: 999999}, api_key: @api_key

        expect(response.status).to eq 404
        expect(json["publication"]).to be nil
        expect(json["error"]).to_not be nil
      end
    end
    context "for a published publication" do
      it "should return an error message" do
        create(:published_publication, id: 12234)

        post :create, publication: {draft_id: 12234}, api_key: @api_key

        expect(response.status).to eq 404
        expect(json["publication"]).to be nil
        expect(json["error"]).to_not be nil
      end
    end
    context "without giving a draft_id" do
      it "should return an error message" do
        post :create, publication: {}, api_key: @api_key

        expect(response.status).to eq 404
        expect(json["publication"]).to be nil
        expect(json["error"]).to_not be nil
      end
    end
  end

  describe "update" do

    context "for a non existing publication id" do
      it "should return an error message" do
        put :update, id: 9999, api_key: @api_key

        expect(response.status).to eq 404
        expect(json['publication']).to be nil
        expect(json['error']).to_not be nil
      end
    end
    context "for a draft publication" do
      it "should return an error message" do
        create(:draft_publication, id: 1234)

        put :update, id: 1234, api_key: @api_key

        expect(response.status).to eq 404
        expect(json['publication']).to be nil
        expect(json['error']).to_not be nil
      end
    end
    context "for a published publication" do
      context "with valid parameters epub_ahead_of_print set" do
        it "should return publication with epub_ahead_of_print set" do
          create(:published_publication, id: 45687)

          put :update, id: 45687, publication: {title: "New test title", epub_ahead_of_print: true}, api_key: @api_key

          expect(json['error']).to be nil
          expect(json["publication"]["epub_ahead_of_print"]).to_not be nil
        end
      end
      context "with valid parameters, epub_ahead_of_print not set" do
        it "should return publication with epub_ahead_of_print not set" do
          create(:published_publication, id: 45687)

          put :update, id: 45687, publication: {title: "New test title", epub_ahead_of_print: false}, api_key: @api_key

          expect(json['error']).to be nil
          expect(json["publication"]["epub_ahead_of_print"]).to be nil
        end
      end
    end
    context "with person inc department" do
      it "should return a publication" do
        publication = create(:published_publication)
        person = create(:person)
        department = create(:department)

        put :update, id: publication.id, publication: {authors: [{id: person.id, departments: [department.as_json]}]}, api_key: @api_key
        publication_new = Publication.find_by_id(publication.id)

        expect(json['error']).to be nil
        expect(json['publication']['authors'][0]['id']).to eq person.id
        expect(json['publication']['authors'][0]['departments'][0]['id']).to eq department.id
        expect(publication_new.current_version.people2publications.size).to eq 1
        expect(publication_new.current_version.people2publications.first.departments2people2publications.count).to eq 1
      end

      it "should return a publication with an author list with presentation string on the form 'first_name last_name, year_of_birth (affiliation 1, affiliation 2)'" do
        person = create(:person, first_name: "Test", last_name: "Person", year_of_birth: 1980)
        publication = create(:published_publication, id: 45687)

        department1 = create(:department, name_sv: "department 1")
        department2 = create(:department, name_sv: "department 2")
        department3 = create(:department, name_sv: "department 3")

        people2publication = create(:people2publication, publication_version: publication.current_version, person: person)

        create(:departments2people2publication, people2publication: people2publication, department: department1)
        create(:departments2people2publication, people2publication: people2publication, department: department2)
        create(:departments2people2publication, people2publication: people2publication, department: department3)

        put :update, id: 45687, publication: {title: "New test title", authors: [{id: person.id, departments: [department1.as_json, department2.as_json, department3.as_json]}]}, api_key: @api_key

        expect(json["publication"]["authors"]).to_not be nil
        expect(json["publication"]["authors"][0]["presentation_string"]).to eq "Test Person, 1980 (department 1, department 2)"
      end
    end

    context "for an existing no deleted and published publication" do
      context "with valid parameters" do
        it "should return updated publication" do
          create(:published_publication, id: 45687)

          put :update, id: 45687, publication: {title: "New test title"}, api_key: @api_key

          expect(json["error"]).to be nil
          expect(json["publication"]).to_not be nil
        end
      end
    end

    context "for an existing no deleted, published and bibl reviewed publication" do
      context "with valid parameters" do
        it "should return updated publication with empty bibl reviewed attributes" do
          create(:published_publication, id: 45687)

          put :update, id: 45687, publication: {title: "New test title"}, api_key: @api_key

          expect(json["error"]).to be nil
          expect(json["publication"]).to_not be nil
          expect(json["publication"]["biblreviewed_at"]).to be nil
          expect(json["publication"]["biblreviewed_by"]).to be nil
        end
      end
    end

  end

end

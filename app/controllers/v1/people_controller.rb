class V1::PeopleController < V1::V1Controller

  api :GET, '/people', 'Not implemented. PersonRecordsController index should be used'
  def index
    render_json(501)
  end

  api :GET, '/people/:id', 'Returns a single person object'
  def show
    personid = params[:id]
    person = Person.find_by_id(personid)
    if person.present?
      @response[:person] = person
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "people.errors.not_found"}: #{params[:id]}")
    end
    render_json
  end

  api :POST, '/people', 'Creates a person object including identifiers if they exist'
  def create
    # Super ugly hack, since front-end cannot send query params on save/update
    skip_update_search_engine = false
    if params[:person][:skip_update_search_engine]
      skip_update_search_engine = params[:person][:skip_update_search_engine]
      params[:person].delete :skip_update_search_engine
    end

    person_params = permitted_params
    parameters = ActionController::Parameters.new(person_params)
    person = Person.new(parameters.permit(:first_name, :last_name, :year_of_birth, :skip_update_search_engine))

    if person.save
      if params[:person][:xaccount].present?
        Identifier.create(person_id: person.id, source_id: Source.find_by_name('xkonto').id, value: params[:person][:xaccount])
      end
      if params[:person][:orcid].present?
        Identifier.create(person_id: person.id, source_id: Source.find_by_name('orcid').id, value: params[:person][:orcid])
      end
      url = url_for(controller: 'people', action: 'create', only_path: true)
      headers['location'] = "#{url}/#{person.id}"
      @response[:person] = person.as_json
      presentation_string = person.presentation_string
      @response[:person][:presentation_string] = presentation_string
      if !skip_update_search_engine
        PeopleSearchEngine.update_search_engine([].push(person))
      end
    else
      error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "people.errors.create_error"}", person.errors.messages)
    end
    render_json(201)
  end

  api :PUT, '/people/:id', 'Updates a specific person object.'
  def update
    person_id = params[:id]
    person = Person.find_by_id(person_id)

    # Super ugly hack, since front-end cannot send query params on save/update
    skip_update_search_engine = false
    if params[:person][:skip_update_search_engine]
      skip_update_search_engine = params[:person][:skip_update_search_engine]
      params[:person].delete :skip_update_search_engine
    end

    if person.present?
# --------------------------------------------------       #
      if params[:person] && params[:person][:xaccount]
        xaccount_source = Source.find_by_name("xkonto")

        # Find any identifier of type "xkonto"
        old_xaccount = person.identifiers.find { |i| i.source_id == xaccount_source.id }
        if old_xaccount
          if params[:person][:xaccount].present?
            old_xaccount.update_attribute(:value, params[:person][:xaccount])
          else
            old_xaccount.destroy
          end
        else
          person.identifiers.create(source_id: xaccount_source.id, value: params[:person][:xaccount])
        end

        params[:person].delete(:xaccount)
      end
# --------------------------------------------------       #
      if params[:person] && params[:person][:orcid]
        orcid_source = Source.find_by_name("orcid")

        # Find any identifier of type "orcid"
        old_orcid = person.identifiers.find { |i| i.source_id == orcid_source.id }
        if old_orcid
          if params[:person][:orcid].present?
            old_orcid.update_attribute(:value, params[:person][:orcid])
          else
            old_orcid.destroy
          end
        else
          person.identifiers.create(source_id: orcid_source.id, value: params[:person][:orcid])
        end

        params[:person].delete(:orcid)
      end
# --------------------------------------------------       #


      if person.update_attributes(permitted_params)
        if !skip_update_search_engine
          # Reload object before update search engine
          person.reload
          PeopleSearchEngine.update_search_engine([].push(person))
        end

        @response[:person] = person
        render_json
      else
        error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "people.errors.update_error"}: #{params[:id]}", person.errors)
        render_json
      end
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "people.errors.not_found"}: #{params[:id]}")
      render_json
    end
  end

  api :DELETE, '/people/:id', 'Deletes a specific person object.'
  def destroy
    person = Person.find_by_id(params[:id])

    if person.present?
      if !person.has_active_publications?
        person.update_attributes(deleted_at: DateTime.now)
        @response[:person] = person.as_json
        PeopleSearchEngine.delete_from_search_engine(person.id)
      else
        # Deleting a person who has active publications would be bad.
        # This is not allowed.
        error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "people.errors.delete_error"}: #{params[:id]}")
      end
      render_json
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "people.errors.not_found"}: #{params[:id]}")
      render_json
    end
  end

  private

  def permitted_params
    params.require(:person).permit(:first_name, :last_name, :year_of_birth, :identifiers, :alternative_names, :xaccount, :orcid)
  end

  # Returns a list of departments that given person id has a relation to
  def affiliations_for_actor(person_id:)
    publication_ids = Publication.where.not(published_at: nil).where(is_deleted: false).map {|publ| publ.id}
    people2publication_ids = People2publication.where('publication_id in (?)', publication_ids).where('person_id = (?)', person_id.to_i).map { |p| p.id}
    department_ids = Departments2people2publication.where('people2publication_id in (?)', people2publication_ids).order(updated_at: :desc).map {|d2p2p| d2p2p.department_id}
    departments = Department.where(id: department_ids)
    affiliations = departments.map {|d| {id: d.id, name: I18n.locale == :en ? d.name_en : d.name_sv}}
    return affiliations.sort_by {|a| a[:name]}
  end
end

class V1::PeopleController < V1::V1Controller

  api :GET, '/people', 'Returns a list of people based on given parameters.'
  param :search_term, String, :desc => 'String query which searches based on any name and identifier that might be present.'
  param :xkonto, String, :desc => 'Searches amongst available xkonto identifiers.'
  def index
    search_term = params[:search_term] || ''
    fetch_xkonto = params[:xkonto] || ''
    affiliation_query = "affiliated = true"
    
    @people = Person.all

    if(params[:ignore_affiliation])
      if(params[:search_term].present?)
        # Always true
        affiliation_query = "1=1"
      else
        # Do not show all people
        @people = Person.none
      end
    end
    

    if fetch_xkonto.present?

      xkonto = fetch_xkonto.downcase

      source_hit = Identifier.where(
        "lower(value) LIKE ?",
        "#{xkonto}"
        ).where(source_id: Source.find_by_name("xkonto").id)
      .select(:person_id)

      @people = @people.where(id: source_hit)

    elsif search_term.present?
      st = search_term.downcase.strip

      alternative_name_hit = AlternativeName.where(
        "(lower(first_name) LIKE ?)
        OR (lower(last_name) LIKE ?)",
        "%#{st}%", "%#{st}%"
        ).select(:person_id)

      source_hit = Identifier.where(
        "lower(value) LIKE ?",
        "%#{st}%"
        ).select(:person_id)

      @people = @people.where(
        "(((lower(first_name) LIKE ?)
          OR (lower(last_name) LIKE ?))
      AND (#{affiliation_query}))
      OR (id IN (?) AND (#{affiliation_query}))
      OR (id IN (?))",
      "%#{st}%",
      "%#{st}%",
      alternative_name_hit,
      source_hit
      )

      if params[:require_xaccount]
        xaccount_people = Identifier.where(source: Source.find_by_name("xkonto")).select(:person_id)
        @people = @people.where(id: xaccount_people)
      end
      
      logger.info "SQL for search gup-people: #{@people.to_sql}"
    end
    return_array = []
    
    @people = @people.paginate(per_page: 30, page: 1)
    
    @people.each do |person|
      #affiliations = affiliations_for_actor(person_id: person.id)
      #affiliations_names = affiliations.map{|d| d[:name]}.uniq[0..1]
      #presentation_string = person.presentation_string(affiliations_names)
      presentation_string = person.presentation_string
      person = person.as_json
      person[:presentation_string] = presentation_string
      #person[:affiliations] = affiliations
      return_array << person
    end
    @response[:people] = return_array
    render_json
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
    person_params = permitted_params
    parameters = ActionController::Parameters.new(person_params)
    obj = Person.new(parameters.permit(:first_name, :last_name, :year_of_birth, :affiliated))

    if obj.save
      if params[:person][:xaccount].present?
        Identifier.create(person_id: obj.id, source_id: Source.find_by_name('xkonto').id, value: params[:person][:xaccount])
      end
      if params[:person][:orcid].present?
        Identifier.create(person_id: obj.id, source_id: Source.find_by_name('orcid').id, value: params[:person][:orcid])
      end
      url = url_for(controller: 'people', action: 'create', only_path: true)
      headers['location'] = "#{url}/#{obj.id}"
      @response[:person] = obj.as_json
      presentation_string = obj.presentation_string
      @response[:person][:presentation_string] = presentation_string
      PeopleSearchEngine.add_to_search_engine(obj)
    else
      error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "people.errors.create_error"}", obj.errors.messages)
    end
    render_json(201)
  end

  api :PUT, '/people/:id', 'Updates a specific person object.'
  def update
    person_id = params[:id]
    person = Person.find_by_id(person_id)
    
    if person.present?
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
      
      if params[:person] && params[:person][:orcid].present?
        orcid_source = Source.find_by_name("orcid")
        
        # Find any identifier of type "orcid"
        old_orcid = person.identifiers.find { |i| i.source_id == orcid_source.id }
        if old_orcid
          old_orcid.update_attribute(:value, params[:person][:orcid])
        else
          person.identifiers.create(source_id: orcid_source.id, value: params[:person][:orcid])
        end

        params[:person].delete(:orcid)
      end
      
      if params[:person] && params[:person][:orcid]
        params[:person].delete(:orcid)
      end
      
      if person.update_attributes(permitted_params)
        @response[:person] = person
        PeopleSearchEngine.update_search_engine(person)
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
        person.update_attribute(:deleted_at, DateTime.now)
        @response[:person] = person.as_json
        PeopleSearchEngine.delete_from_search_engine(person.id)
      else
        # Deleting a person who has active publications would be bad.
        # This is not allowed.
        error_msg(ErrorCodes::VALIDATION_ERROR,
                  "#{I18n.t "people.errors.delete_error"}: #{params[:id]}")
      end
      render_json
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "people.errors.not_found"}: #{params[:id]}")
      render_json
    end
  end  
  
  private
  def permitted_params
    params.require(:person).permit(:first_name, :last_name, :year_of_birth, :affiliated, :identifiers, :alternative_names, :xaccount, :orcid)
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

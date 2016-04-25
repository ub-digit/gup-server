class V1::ReportsController < V1::V1Controller
  def create
    publist = Publication.all
    
    if params[:filter]
      if params[:filter][:start_year] && params[:filter][:end_year]
        versions_for_year = PublicationVersion
                            .where("pubyear >= ?", params[:filter][:start_year])
                            .where("pubyear <= ?", params[:filter][:end_year])
                            .select(:publication_id)
        publist = publist.where(id: versions_for_year)
      end

      if params[:filter][:publication_types]
        versions_for_pubtype = PublicationVersion
                               .where("publication_type IN (?)", params[:filter][:publication_types])
                               .select(:publication_id)
        publist = publist.where(id: versions_for_pubtype)
      end
      
      if params[:filter][:department] || params[:filter][:faculty]
        if params[:filter][:faculty]
          department_ids = Department.where(faculty_id: params[:filter][:faculty])
                                    .select(:id)
        else
          department_ids = params[:filter][:department]
        end
        affiliations_for_department = Departments2people2publication
                                     .where(department_id: department_ids)
                                     .select(:people2publication_id)
        publication_versions_for_affiliation = People2publication
                                               .where(id: affiliations_for_department)
                                               .select(:publication_version_id)
        versions_for_departments = PublicationVersion
                                   .where(id: publication_versions_for_affiliation)
                                   .select(:publication_id)

        publist = publist.where(id: versions_for_departments)
      end

      if params[:filter][:person]
        publication_versions_for_affiliation = People2publication
                                               .where(person_id: params[:filter][:person])
                                               .select(:publication_version_id)
        versions_for_person = PublicationVersion
                              .where(id: publication_versions_for_affiliation)
                              .select(:publication_id)

        publist = publist.where(id: versions_for_person)
      end
    end
    
    
    @response['report'] = {
      count: publist.count
    }
    render_json
  end
end

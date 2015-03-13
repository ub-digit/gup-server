require 'active_resource'

class Publication < ActiveResource::Base
  self.site = Rails.application.config.services[:publication][:site]
  self.element_name = "publication"
  around_save :prepare_send


  def prepare_send
    @sending = true
    yield
    @sending = false    
  end

  def to_people
    return nil unless respond_to?(:people2publications)
    people2publications.map do |p2p| 
      person = ::Person.find(p2p.person_id)
      person.department_name = p2p.department_name
      person
    end
  end

  def to_people2publications
    return nil unless respond_to?(:people)
    people.map do |p|
      people2publications = {}
      people2publications[:person_id] = p.id  
      people2publications[:position] = p.position
      people2publications[:department_name] = p.department_name
      people2publications
    end
  end


  def as_json(options = {})
    if @sending
      result = super(except: [:people])
      tmp = to_people2publications
      result["people2publications"] = tmp
    else
      result = super(except: [:people2publications])
      result["people"] = to_people
    end 
    result
  end
end

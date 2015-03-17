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
      person.departments = p2p.departments2people2publications

      tmp_arr = []
      p2p.departments2people2publications.each do |d2p2p|
        tmp_arr << {name: d2p2p.name}
      end
      person.departments = tmp_arr
      
      person
    end
  end

  def to_people2publications
    return nil unless respond_to?(:people)
    people.map.with_index do |p, i|
      people2publications = {}
      people2publications[:person_id] = p.id  
      people2publications[:position] = i + 1
      people2publications[:departments2people2publications] = p.departments
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
      result["id"] = result["pubid"]
    end 
    result
  end
end

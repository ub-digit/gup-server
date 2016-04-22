FactoryGirl.define do

  sequence :p2p_position do |n|
    "#{n}"
  end

  factory :people2publication do
    association :publication_version, factory: [:publication_version]
    association :person, factory: [:person]
    position {generate :p2p_position}
  end

end

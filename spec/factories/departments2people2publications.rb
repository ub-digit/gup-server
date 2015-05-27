FactoryGirl.define do

  sequence :d2p2p_position do |n|
    "#{n}"
  end

  factory :departments2people2publication do
    association :department, factory: [:department]
    association :people2publication, factory: [:people2publication]
    position {generate :d2p2p_position}
  end

end

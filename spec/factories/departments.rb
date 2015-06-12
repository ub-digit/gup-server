FactoryGirl.define do

  sequence :department_id do |n|
    n+10000
  end

  sequence :department_name do |n|
    "department_#{n}"
  end

  factory :department do
    id {generate :department_id}
    name {generate :department_name}
  end

end

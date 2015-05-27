FactoryGirl.define do

  sequence :department_name do |n|
    "department_#{n}"
  end

  factory :department do
    name {generate :department_name}
  end

end

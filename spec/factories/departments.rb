FactoryGirl.define do

  sequence :department_id do |n|
    n+10000
  end

  sequence :department_name_sv do |n|
    "department_sv_#{n}"
  end

  sequence :department_name_en do |n|
    "department_en_#{n}"
  end

  factory :department do
    id {generate :department_id}
    name_sv {generate :department_name_sv}
    name_en {generate :department_name_en}
    start_year 1900
    end_year 2100


    trait :external do
      is_internal false
    end

    factory :external_department, traits: [:external]
  end

end

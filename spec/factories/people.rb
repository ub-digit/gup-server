FactoryGirl.define do

  sequence :person_last_name do |n|
    "last_name_#{n}"
  end

  factory :person do
    last_name {generate :person_last_name}

    factory :xkonto_person do
      after(:create) do |person|
        create(:xkonto_identifier, person: person, value: "xtest")
      end
    end

    factory :xkonto_person2 do
      after(:create) do |person|
        create(:xkonto_identifier, person: person, value: "xtest2")
      end
    end
  end

end

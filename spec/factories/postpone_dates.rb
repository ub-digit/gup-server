FactoryGirl.define do
  factory :postpone_date do
    deleted_at nil
    postponed_until DateTime.now - 1
    
    trait :postponed do
      postponed_until DateTime.now + 1
    end

    factory :postponed_postpone_date, traits: [:postponed]

  end
end

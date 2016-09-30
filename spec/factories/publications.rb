FactoryGirl.define do
  factory :publication do
    deleted_at nil
    process_state "PREDRAFT"
    after(:build) do |pub|
      if pub.current_version.nil?
        pub.current_version = create(:publication_version, publication: pub)
      end
    end
    
    trait :draft do
      published_at nil
      process_state "DRAFT"
    end

    trait :predraft do
      published_at nil
      process_state "PREDRAFT"
    end

    trait :deleted do
      deleted_at DateTime.now
    end

    trait :unreviewed do
      after(:build) do |pub| 
        pub.current_version = create(:unreviewed_publication_version, publication: pub)
      end
    end
    
    trait :postponed do
      after(:build) do |pub|
        create(:postponed_postpone_date, publication: pub)
      end
    end

    trait :published do
      published_at DateTime.now
    end

    factory :deleted_publication, traits: [:deleted]

    factory :predraft_publication, traits: [:predraft]

    factory :draft_publication, traits: [:draft]

    factory :unreviewed_publication, traits: [:unreviewed, :published]

    factory :delayed_publication, traits: [:postponed, :unreviewed, :published]

    factory :published_publication, traits: [:published]
  end
end

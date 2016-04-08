FactoryGirl.define do
  factory :publication do
    deleted_at nil
    published_at DateTime.now
    after(:build) do |pub| 
      pub.current_version = create(:publication_version, publication: pub)
    end
    
    trait :draft do
      published_at nil
    end

    trait :deleted do
      deleted_at DateTime.now
    end

    trait :unreviewed do
      after(:build) do |pub| 
        pub.current_version = create(:unreviewed_publication_version, publication: pub)
      end
    end

    trait :unpostponed do
      biblreview_postponed_until DateTime.now - 1
    end
    
    trait :postponed do
      biblreview_postponed_until DateTime.now + 1
    end

    factory :deleted_publication, traits: [:deleted]

    factory :draft_publication, traits: [:draft]

    factory :unreviewed_publication, traits: [:unpostponed, :unreviewed]

    factory :delayed_publication, traits: [:postponed, :unreviewed]
  end
end

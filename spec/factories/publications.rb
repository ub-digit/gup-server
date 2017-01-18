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
      process_state "UNKNOWN"
    end

    trait :unreviewed do
      after(:build) do |pub|
        current_version = create(:unreviewed_publication_version, publication: pub)
        pub.current_version = current_version
        person = create(:xkonto_person)
        people2publication = create(:people2publication, publication_version: current_version, person: person, reviewed_at: DateTime.now, reviewed_publication_version_id: current_version.id)
        department = create(:department, is_internal: true)
        create(:departments2people2publication, people2publication: people2publication, department: department)
      end
      process_state "UNKNOWN"
    end

    trait :postponed do
      after(:build) do |pub|
        create(:postponed_postpone_date, publication: pub)
      end
      process_state "UNKNOWN"
    end

    trait :published do
      published_at DateTime.now
      process_state "UNKNOWN"
    end

    factory :deleted_publication, traits: [:deleted]

    factory :predraft_publication, traits: [:predraft]

    factory :draft_publication, traits: [:draft]

    factory :unreviewed_publication, traits: [:unreviewed, :published]

    factory :delayed_publication, traits: [:postponed, :unreviewed, :published]

    factory :published_publication, traits: [:published]
  end
end

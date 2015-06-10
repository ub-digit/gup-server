FactoryGirl.define do

  sequence :pubid do |n|
    "#{n}"
  end

  factory :publication do
    pubid {generate :pubid}
    publication_type 'journal-articles'
    is_deleted false
    published_at DateTime.now
    title "A publication title"
    pubyear 1999
    sourcetitle "Source title"

    trait :draft do
      published_at nil
    end

    trait :deleted do
      is_deleted true
    end

    factory :deleted_publication, traits: [:deleted]

    factory :draft_publication, traits: [:draft]
  end

end
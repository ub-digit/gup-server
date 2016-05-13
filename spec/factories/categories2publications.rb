FactoryGirl.define do
  factory :categories2publication do
    association :category, factory: [:category]
    association :publication_version, factory: [:publication_version]
  end

end

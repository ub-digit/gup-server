FactoryGirl.define do
  factory :series2publication do
    association :serie, factory: [:serie]
    association :publication_version, factory: [:publication_version]
  end

end

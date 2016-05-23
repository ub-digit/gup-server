FactoryGirl.define do
  factory :message do
    news
    start_date Date.today - 1.day
    message "TestMessage"

    trait :news do
      message_type 'NEWS'
    end

    trait :alert do
      message_type 'ALERT'
    end

    factory :news_message, traits: [:news]
    factory :alert_message, traits: [:alert]
  end

end

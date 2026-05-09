FactoryBot.define do
  factory :task do
    title { "Review lab results" }
    description { "" }
    scheduled_at { Time.zone.parse("2026-05-09 10:00:00") }
    status { :new }
  end
end

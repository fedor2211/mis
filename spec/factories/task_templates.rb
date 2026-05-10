FactoryBot.define do
  factory :task_template do
    title { "Review lab results" }
    description { "" }
    periodicity { :daily }
    scheduled_at { 1.day.from_now.change(hour: 10, min: 0, sec: 0) }
    ndays { 1 }
    month_day { nil }
    active_until { nil }
  end
end

FactoryBot.define do
  factory :tag do
    sequence(:name) { |number| "tag-#{number}" }
    persistent { false }
  end
end

require "rails_helper"

RSpec.describe Task do
  it "has many tags through task tags" do
    expect(described_class.reflect_on_association(:task_tags).macro).to eq(:has_many)
    expect(described_class.reflect_on_association(:tags).macro).to eq(:has_many)
  end

  it "stores supported task statuses" do
    expect(described_class.statuses).to eq(
      "new" => 0,
      "in_progress" => 1,
      "completed" => 2,
      "cancelled" => 3
    )
  end
end

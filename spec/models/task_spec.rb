require "rails_helper"

RSpec.describe Task do
  it "stores supported task statuses" do
    expect(described_class.statuses).to eq(
      "new" => 0,
      "in_progress" => 1,
      "completed" => 2,
      "cancelled" => 3
    )
  end
end

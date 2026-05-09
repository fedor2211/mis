require "rails_helper"

RSpec.describe Tasks::ListContract do
  it "accepts supported filters" do
    result = described_class.new.call(
      status: "completed",
      scheduled_at: "2026-05-09",
      created_at: "2026-05-10"
    )

    expect(result).to be_success
  end

  it "rejects invalid dates" do
    result = described_class.new.call(scheduled_at: "not-a-date")

    expect(result).to be_failure
    expect(result.errors.to_h.keys).to include(:scheduled_at)
  end
end

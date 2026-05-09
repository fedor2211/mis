require "rails_helper"

RSpec.describe Tasks::CreateContract do
  it "accepts valid task attributes" do
    create(:tag, name: "reports")

    result = described_class.new.call(
      title: "Review lab results",
      description: "",
      scheduled_at: "2026-05-09T10:00:00Z",
      status: "in_progress",
      tags: [ "reports" ]
    )

    expect(result).to be_success
  end

  it "requires a title and scheduled date" do
    result = described_class.new.call(title: "", scheduled_at: nil)

    expect(result).to be_failure
    expect(result.errors.to_h.keys).to include(:title, :scheduled_at)
  end

  it "rejects unsupported statuses" do
    result = described_class.new.call(
      title: "Review lab results",
      scheduled_at: "2026-05-09T10:00:00Z",
      status: "archived"
    )

    expect(result).to be_failure
    expect(result.errors.to_h.keys).to include(:status)
  end

  it "rejects unknown tags" do
    result = described_class.new.call(
      title: "Review lab results",
      scheduled_at: "2026-05-09T10:00:00Z",
      tags: [ "missing" ]
    )

    expect(result).to be_failure
    expect(result.errors.to_h.keys).to include(:tags)
  end

  it "rejects tag names that do not match exactly" do
    create(:tag, name: "reports")

    result = described_class.new.call(
      title: "Review lab results",
      scheduled_at: "2026-05-09T10:00:00Z",
      tags: [ "Reports" ]
    )

    expect(result).to be_failure
    expect(result.errors.to_h.keys).to include(:tags)
  end
end

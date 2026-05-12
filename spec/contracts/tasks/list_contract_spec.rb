require "rails_helper"

RSpec.describe Tasks::ListContract do
  it "accepts supported filters" do
    create(:tag, name: "reports")

    result = described_class.new.call(
      status: "completed",
      scheduled_at: "2026-05-09",
      created_at: "2026-05-10",
      page: "2",
      per_page: "50",
      tags: [ "reports" ]
    )

    expect(result).to be_success
    expect(result.to_h).to include(page: 2, per_page: 50)
  end

  it "rejects non-positive pagination" do
    result = described_class.new.call(page: "0", per_page: "0")

    expect(result).to be_failure
    expect(result.errors.to_h.keys).to include(:page, :per_page)
  end

  it "rejects invalid dates" do
    result = described_class.new.call(scheduled_at: "not-a-date")

    expect(result).to be_failure
    expect(result.errors.to_h.keys).to include(:scheduled_at)
  end

  it "rejects unknown tags" do
    result = described_class.new.call(tags: [ "missing" ])

    expect(result).to be_failure
    expect(result.errors.to_h.keys).to include(:tags)
  end

  it "rejects tag names that do not match exactly" do
    create(:tag, name: "reports")

    result = described_class.new.call(tags: [ "Reports" ])

    expect(result).to be_failure
    expect(result.errors.to_h.keys).to include(:tags)
  end
end

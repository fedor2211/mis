require "rails_helper"

RSpec.describe Tasks::UpdateContract do
  it "accepts valid task attributes" do
    create(:tag, name: "reports")

    result = described_class.new.call(
      title: "Review lab results",
      tags: [ "reports" ]
    )

    expect(result).to be_success
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

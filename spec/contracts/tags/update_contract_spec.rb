require "rails_helper"

RSpec.describe Tags::UpdateContract do
  it "accepts valid tag attributes" do
    result = described_class.new.call(name: "urgent")

    expect(result).to be_success
  end

  it "rejects an empty name" do
    result = described_class.new.call(name: "")

    expect(result).to be_failure
    expect(result.errors.to_h.keys).to include(:name)
  end

  it "allows keeping the current tag name" do
    tag = create(:tag, name: "urgent")

    result = described_class.new(tag_id: tag.id).call(name: "Urgent")

    expect(result).to be_success
  end

  it "rejects duplicate names case-insensitively" do
    tag = create(:tag, name: "urgent")
    create(:tag, name: "blocked")

    result = described_class.new(tag_id: tag.id).call(name: "Blocked")

    expect(result).to be_failure
    expect(result.errors.to_h).to include(name: [ "has already been taken" ])
  end
end

require "rails_helper"

RSpec.describe Tags::CreateContract do
  it "accepts valid tag attributes" do
    result = described_class.new.call(name: "urgent")

    expect(result).to be_success
  end

  it "requires a name" do
    result = described_class.new.call(name: "")

    expect(result).to be_failure
    expect(result.errors.to_h.keys).to include(:name)
  end

  it "rejects duplicate names case-insensitively" do
    create(:tag, name: "urgent")

    result = described_class.new.call(name: "Urgent")

    expect(result).to be_failure
    expect(result.errors.to_h).to include(name: [ "has already been taken" ])
  end
end

require "rails_helper"

RSpec.describe TaskTemplates::ListContract do
  it "accepts pagination" do
    result = described_class.new.call(page: "2", per_page: "50")

    expect(result).to be_success
    expect(result.to_h).to include(page: 2, per_page: 50)
  end

  it "rejects non-positive pagination" do
    result = described_class.new.call(page: "0", per_page: "0")

    expect(result).to be_failure
    expect(result.errors.to_h.keys).to include(:page, :per_page)
  end
end

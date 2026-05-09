require "rails_helper"

RSpec.describe Tag do
  it "defines persistent system tag names" do
    expect(described_class::SYSTEM_NAMES).to contain_exactly("reports", "operations", "calls")
  end

  it "downcases the name before saving" do
    tag = create(:tag, name: "Urgent")

    expect(tag.reload.name).to eq("urgent")
  end
end

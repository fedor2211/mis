require "rails_helper"

RSpec.describe Tag do
  it "has many tasks through task tags" do
    expect(described_class.reflect_on_association(:task_tags).macro).to eq(:has_many)
    expect(described_class.reflect_on_association(:tasks).macro).to eq(:has_many)
    expect(described_class.reflect_on_association(:task_template_tags).macro).to eq(:has_many)
    expect(described_class.reflect_on_association(:task_templates).macro).to eq(:has_many)
  end

  it "defines persistent system tag names" do
    expect(described_class::SYSTEM_NAMES).to contain_exactly("reports", "operations", "calls")
  end

  it "downcases the name before saving" do
    tag = create(:tag, name: "Urgent")

    expect(tag.reload.name).to eq("urgent")
  end
end

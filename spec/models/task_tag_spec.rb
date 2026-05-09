require "rails_helper"

RSpec.describe TaskTag do
  it "belongs to a task and tag" do
    expect(described_class.reflect_on_association(:task).macro).to eq(:belongs_to)
    expect(described_class.reflect_on_association(:tag).macro).to eq(:belongs_to)
  end
end

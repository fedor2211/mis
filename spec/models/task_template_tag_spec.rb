require "rails_helper"

RSpec.describe TaskTemplateTag do
  it "belongs to a task template and tag" do
    expect(described_class.reflect_on_association(:task_template).macro).to eq(:belongs_to)
    expect(described_class.reflect_on_association(:tag).macro).to eq(:belongs_to)
  end
end

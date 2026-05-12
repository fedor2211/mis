require "rails_helper"

RSpec.describe TaskTemplates::ShowService do
  subject(:call_service) { described_class.call(task_template.id) }

  let(:task_template) { create(:task_template, title: "Template") }

  it "returns a task template" do
    expect(call_service).to include(success: true, task_template: task_template)
  end
end

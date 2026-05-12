require "rails_helper"

RSpec.describe TaskTemplates::DestroyService do
  subject(:call_service) { described_class.call(task_template.id) }

  let!(:task_template) { create(:task_template, title: "Template") }
  let!(:future_task) { create(:task, task_template: task_template, scheduled_at: 1.day.from_now, status: :new) }
  let!(:past_task) { create(:task, task_template: task_template, scheduled_at: 1.day.ago, status: :new) }

  it "cancels future tasks and destroys the task template" do
    result = nil

    expect { result = call_service }.to change(TaskTemplate, :count).by(-1)
    expect(result).to include(success: true, task_template: task_template)
    expect(future_task.reload.status).to eq("cancelled")
    expect(past_task.reload.status).to eq("new")
  end
end

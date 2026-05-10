require "rails_helper"

RSpec.describe GenerateTaskTemplateTasksJob do
  it "generates tasks for a persisted template" do
    task_template = create(:task_template)

    expect { described_class.perform_now(task_template_id: task_template.id, month: Date.current.next_month) }.to change(Task, :count)
  end
end

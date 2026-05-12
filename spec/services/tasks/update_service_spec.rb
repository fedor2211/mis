require "rails_helper"

RSpec.describe Tasks::UpdateService do
  subject(:call_service) { described_class.call(task.id, attributes) }

  let(:task) { create(:task, title: "Initial title", tags: [ old_tag ]) }
  let(:old_tag) { create(:tag, name: "calls") }
  let!(:new_tag) { create(:tag, name: "reports") }
  let(:attributes) { { title: "Updated title", status: "cancelled", tags: [ "reports" ] } }

  it "updates a task and replaces tags" do
    expect(call_service).to include(success: true, task: task)
    expect(task.reload).to have_attributes(title: "Updated title", status: "cancelled")
    expect(task.tags).to contain_exactly(new_tag)
  end

  context "with invalid attributes" do
    let(:attributes) { { title: "" } }

    it "returns validation errors" do
      expect(call_service).to include(success: false)
      expect(call_service[:errors].keys).to include(:title)
      expect(task.reload.title).to eq("Initial title")
    end
  end

  context "with a duplicate template scheduled_at" do
    let(:task_template) { create(:task_template) }
    let(:duplicate_scheduled_at) { 3.days.from_now.change(usec: 0) }
    let(:task) { create(:task, task_template: task_template, scheduled_at: 2.days.from_now.change(usec: 0)) }
    let!(:duplicate_task) { create(:task, task_template: task_template, scheduled_at: duplicate_scheduled_at) }
    let(:attributes) { { scheduled_at: duplicate_scheduled_at.iso8601 } }

    it "returns validation errors" do
      expect(call_service).to include(success: false)
      expect(call_service[:errors]).to include(scheduled_at: [ "has already been taken for this task template" ])
    end
  end

  context "with a templated task scheduled after the nearest future task" do
    let(:task_template) { create(:task_template) }
    let(:nearest_future_scheduled_at) { 3.days.from_now.change(usec: 0) }
    let(:task) { create(:task, task_template: task_template, scheduled_at: 2.days.from_now.change(usec: 0)) }
    let!(:nearest_future_task) { create(:task, task_template: task_template, scheduled_at: nearest_future_scheduled_at) }
    let(:attributes) { { scheduled_at: (nearest_future_scheduled_at + 1.hour).iso8601 } }

    it "returns validation errors" do
      expect(call_service).to include(success: false)
      expect(call_service[:errors]).to include(
        scheduled_at: [ "must not be greater than nearest future task from same template" ]
      )
    end
  end
end

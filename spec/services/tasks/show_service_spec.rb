require "rails_helper"

RSpec.describe Tasks::ShowService do
  subject(:call_service) { described_class.call(task.id) }

  let(:task) { create(:task, title: "Call patient") }

  it "returns a task" do
    expect(call_service).to include(success: true, task: task)
  end
end

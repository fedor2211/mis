require "rails_helper"

RSpec.describe Tasks::DestroyService do
  subject(:call_service) { described_class.call(task.id) }

  let!(:task) { create(:task, title: "Remove task") }

  it "destroys a task" do
    result = nil

    expect { result = call_service }.to change(Task, :count).by(-1)
    expect(result).to include(success: true, task: task)
  end
end

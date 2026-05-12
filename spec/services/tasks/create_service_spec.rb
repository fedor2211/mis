require "rails_helper"

RSpec.describe Tasks::CreateService do
  subject(:call_service) { described_class.call(attributes) }

  let!(:tag) { create(:tag, name: "reports") }
  let(:scheduled_at) { 1.day.from_now.change(usec: 0) }
  let(:attributes) do
    {
      title: "Check patient chart",
      description: "Review medications",
      scheduled_at: scheduled_at.iso8601,
      status: "in_progress",
      tags: [ "reports" ]
    }
  end

  it "creates a task with tags" do
    result = nil

    expect { result = call_service }.to change(Task, :count).by(1)
    expect(result).to include(success: true)
    expect(result[:task]).to have_attributes(
      title: "Check patient chart",
      description: "Review medications",
      status: "in_progress"
    )
    expect(result[:task].tags).to contain_exactly(tag)
  end

  context "with invalid attributes" do
    let(:attributes) { { title: "", scheduled_at: scheduled_at.iso8601 } }

    it "returns validation errors" do
      expect { call_service }.not_to change(Task, :count)
      expect(call_service).to include(success: false)
      expect(call_service[:errors].keys).to include(:title)
    end
  end

  context "with an unknown tag" do
    let(:attributes) { super().merge(tags: [ "missing" ]) }

    it "returns validation errors" do
      expect { call_service }.not_to change(Task, :count)
      expect(call_service).to include(success: false)
      expect(call_service[:errors].keys).to include(:tags)
    end
  end
end

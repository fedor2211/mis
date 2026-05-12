require "rails_helper"

RSpec.describe TaskTemplates::CreateService do
  subject(:call_service) { described_class.call(attributes) }

  let!(:tag) { create(:tag, name: "reports") }
  let(:scheduled_at) { 1.day.from_now.change(usec: 0) }
  let(:attributes) do
    {
      title: "Review labs",
      description: "Morning review",
      scheduled_at: scheduled_at.iso8601,
      periodicity: "daily",
      ndays: 1,
      tags: [ "reports" ]
    }
  end

  before do
    ActiveJob::Base.queue_adapter = :test
    clear_enqueued_jobs
  end

  it "creates a task template with tags and enqueues task generation" do
    result = nil

    expect { result = call_service }.to change(TaskTemplate, :count).by(1)
      .and have_enqueued_job(GenerateTaskTemplateTasksJob)
    expect(result).to include(success: true)
    expect(result[:task_template]).to have_attributes(
      title: "Review labs",
      description: "Morning review",
      periodicity: "daily",
      ndays: 1
    )
    expect(result[:task_template].tags).to contain_exactly(tag)
  end

  context "with certain dates" do
    let(:for_date) { 2.days.from_now.to_date }
    let(:attributes) do
      {
        title: "Review labs",
        scheduled_at: scheduled_at.iso8601,
        for_dates: [ for_date.iso8601 ],
        tags: [ "reports" ]
      }
    end

    it "stores dates and uses for_dates periodicity" do
      result = call_service

      expect(result).to include(success: true)
      expect(result[:task_template]).to have_attributes(periodicity: "for_dates", dates: [ for_date ])
    end
  end

  context "with invalid attributes" do
    let(:attributes) { { title: "", scheduled_at: scheduled_at.iso8601, periodicity: "daily" } }

    it "returns validation errors" do
      expect { call_service }.not_to change(TaskTemplate, :count)
      expect(call_service).to include(success: false)
      expect(call_service[:errors].keys).to include(:title, :ndays)
    end
  end

  context "with an unknown tag" do
    let(:attributes) { super().merge(tags: [ "missing" ]) }

    it "returns validation errors" do
      expect { call_service }.not_to change(TaskTemplate, :count)
      expect(call_service).to include(success: false)
      expect(call_service[:errors].keys).to include(:tags)
    end
  end
end

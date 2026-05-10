require "rails_helper"

RSpec.describe Tasks::UpdateContract do
  it "accepts valid task attributes" do
    create(:tag, name: "reports")

    result = described_class.new.call(
      title: "Review lab results",
      tags: [ "reports" ]
    )

    expect(result).to be_success
  end

  it "rejects unknown tags" do
    result = described_class.new.call(tags: [ "missing" ])

    expect(result).to be_failure
    expect(result.errors.to_h.keys).to include(:tags)
  end

  it "rejects tag names that do not match exactly" do
    create(:tag, name: "reports")

    result = described_class.new.call(tags: [ "Reports" ])

    expect(result).to be_failure
    expect(result.errors.to_h.keys).to include(:tags)
  end

  it "rejects scheduled dates that are not in the future" do
    result = described_class.new.call(scheduled_at: 1.minute.ago.iso8601)

    expect(result).to be_failure
    expect(result.errors.to_h.keys).to include(:scheduled_at)
  end

  context "with a templated task" do
    let(:task_template) { create(:task_template) }
    let(:current_scheduled_at) { 2.days.from_now.change(usec: 0) }
    let(:nearest_future_scheduled_at) { 3.days.from_now.change(usec: 0) }
    let(:task) { create(:task, task_template: task_template, scheduled_at: current_scheduled_at) }

    it "rejects a duplicate template scheduled_at" do
      create(:task, task_template: task_template, scheduled_at: nearest_future_scheduled_at)

      result = described_class.new(task: task).call(scheduled_at: nearest_future_scheduled_at.iso8601)

      expect(result).to be_failure
      expect(result.errors.to_h.fetch(:scheduled_at)).to include("has already been taken for this task template")
    end

    it "rejects scheduled_at greater than the nearest future task from the same template" do
      create(:task, task_template: task_template, scheduled_at: nearest_future_scheduled_at)

      result = described_class.new(task: task).call(scheduled_at: (nearest_future_scheduled_at + 1.hour).iso8601)

      expect(result).to be_failure
      expect(result.errors.to_h.fetch(:scheduled_at)).to include(
        "must not be greater than nearest future task from same template"
      )
    end

    it "allows scheduled_at before the nearest future task from the same template" do
      create(:task, task_template: task_template, scheduled_at: nearest_future_scheduled_at)

      result = described_class.new(task: task).call(scheduled_at: (nearest_future_scheduled_at - 1.hour).iso8601)

      expect(result).to be_success
    end

    it "allows scheduled_at when there is no nearest future task from the same template" do
      create(:task, task_template: task_template, scheduled_at: current_scheduled_at - 1.day)

      result = described_class.new(task: task).call(scheduled_at: (current_scheduled_at + 1.day).iso8601)

      expect(result).to be_success
    end
  end
end

require "rails_helper"

RSpec.describe GenerateMonthlyTasksJob do
  subject(:perform_job) { described_class.perform_now(month) }

  let(:month) { Date.current.next_month.beginning_of_month }
  let!(:active_template) { create(:task_template, active_until: month.end_of_month) }
  let!(:second_active_template) { create(:task_template, active_until: month.end_of_month) }
  let!(:inactive_template) { create(:task_template, active_until: month.prev_month.end_of_month) }

  before do
    active_template.update_columns(created_at: month.in_time_zone.change(hour: 9))
    second_active_template.update_columns(created_at: month.in_time_zone.change(hour: 9))
    inactive_template.update_columns(created_at: month.in_time_zone.change(hour: 9))
  end

  it "generates tasks only for active templates" do
    perform_job

    expect(Task.where(task_template: active_template)).to exist
    expect(Task.where(task_template: inactive_template)).not_to exist
  end

  it "logs and continues when one template fails" do
    original_call = TaskTemplates::GenerateTasksService.method(:call)
    call_count = 0
    allow(TaskTemplates::GenerateTasksService).to receive(:call) do |*args, **kwargs|
      call_count += 1
      raise StandardError, "boom" if call_count == 1

      original_call.call(*args, **kwargs)
    end

    expect(Rails.logger).to receive(:error).at_least(:once)
    perform_job
    expect(Task.where(task_template: second_active_template)).to exist
  end
end

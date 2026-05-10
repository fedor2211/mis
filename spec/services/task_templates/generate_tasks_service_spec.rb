require "rails_helper"

RSpec.describe TaskTemplates::GenerateTasksService do
  subject(:call_service) { described_class.call(template: task_template, month: month) }

  let(:month) { Date.current.next_month.beginning_of_month }
  let(:scheduled_at) { month.in_time_zone.change(hour: 14, min: 30) }
  let(:task_template) { create(:task_template, periodicity: periodicity, ndays: ndays, month_day: month_day, scheduled_at: scheduled_at) }
  let(:periodicity) { :daily }
  let(:ndays) { 2 }
  let(:month_day) { nil }

  before do
    task_template.update_columns(created_at: month.in_time_zone.change(hour: 9))
  end

  it "generates daily tasks by interval using template time" do
    call_service

    expect(Task.where(task_template: task_template)).to exist
    expect(Task.where(task_template: task_template).pluck(:scheduled_at).map { |time| time.in_time_zone.min }).to all(eq(30))
  end

  context "with monthly periodicity" do
    let(:periodicity) { :monthly }
    let(:ndays) { nil }
    let(:month_day) { 31 }
    let(:month) { Date.new(Date.current.next_year.year, 4, 1) }

    it "skips invalid month days" do
      expect { call_service }.not_to change(Task, :count)
    end
  end

  context "with odd days periodicity" do
    let(:periodicity) { :odd_days }
    let(:ndays) { nil }

    it "generates only odd day numbers" do
      call_service

      expect(Task.where(task_template: task_template).pluck(:scheduled_at).map { |time| time.to_date.day }).to all(be_odd)
    end
  end

  context "with even days periodicity" do
    let(:periodicity) { :even_days }
    let(:ndays) { nil }

    it "generates only even day numbers" do
      call_service

      expect(Task.where(task_template: task_template).pluck(:scheduled_at).map { |time| time.to_date.day }).to all(be_even)
    end
  end

  context "with for dates periodicity" do
    let(:periodicity) { :for_dates }
    let(:ndays) { nil }
    let(:dates) { [ month.to_date + 2.days, month.to_date + 5.days ] }
    let(:task_template) do
      create(:task_template, periodicity: periodicity, ndays: ndays, month_day: month_day, scheduled_at: scheduled_at, dates: dates)
    end

    it "generates tasks only for stored dates and associates them to the template" do
      call_service

      generated_tasks = Task.where(task_template: task_template)
      expect(generated_tasks.pluck(:scheduled_at).map(&:to_date)).to contain_exactly(*dates)
      expect(generated_tasks.count).to eq(2)
    end
  end

  it "logs and continues when one task creation fails" do
    original_create = Task.method(:create!)
    call_count = 0
    allow(Task).to receive(:create!) do |*args, **kwargs|
      call_count += 1
      raise ActiveRecord::RecordInvalid if call_count == 1

      original_create.call(*args, **kwargs)
    end

    expect(Rails.logger).to receive(:error).at_least(:once)
    expect { call_service }.to change(Task, :count)
  end
end

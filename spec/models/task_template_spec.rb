require "rails_helper"

RSpec.describe TaskTemplate do
  it "has many tasks and tags" do
    expect(described_class.reflect_on_association(:tasks).macro).to eq(:has_many)
    expect(described_class.reflect_on_association(:task_template_tags).macro).to eq(:has_many)
    expect(described_class.reflect_on_association(:tags).macro).to eq(:has_many)
  end

  it "stores supported periodicities" do
    expect(described_class.periodicities).to eq(
      "daily" => 0,
      "monthly" => 1,
      "odd_days" => 2,
      "even_days" => 3,
      "for_dates" => 4
    )
  end

  it "filters templates active for a month" do
    month = Date.current.next_month.beginning_of_month
    active_template = create(:task_template, active_until: month.end_of_month)
    inactive_template = create(:task_template, active_until: month.prev_month.end_of_month)
    always_active_template = create(:task_template, active_until: nil)
    for_dates_template = create(:task_template, periodicity: :for_dates, dates: [ month ], active_until: month.end_of_month)

    expect(described_class.active_for_month(month)).to contain_exactly(active_template, always_active_template)
    expect(described_class.active_for_month(month)).not_to include(inactive_template, for_dates_template)
  end
end

require "rails_helper"

RSpec.describe TaskTemplates::CreateContract do
  let(:scheduled_at) { 1.day.from_now.iso8601 }

  it "accepts daily settings with ndays" do
    result = described_class.new.call(title: "Daily", periodicity: "daily", scheduled_at: scheduled_at, ndays: 2)

    expect(result).to be_success
  end

  it "requires ndays for daily settings" do
    result = described_class.new.call(title: "Daily", periodicity: "daily", scheduled_at: scheduled_at)

    expect(result).to be_failure
    expect(result.errors.to_h.keys).to include(:ndays)
  end

  it "accepts monthly settings with month day" do
    result = described_class.new.call(title: "Monthly", periodicity: "monthly", scheduled_at: scheduled_at, month_day: 15)

    expect(result).to be_success
  end

  it "rejects invalid month days" do
    result = described_class.new.call(title: "Monthly", periodicity: "monthly", scheduled_at: scheduled_at, month_day: 32)

    expect(result).to be_failure
    expect(result.errors.to_h.keys).to include(:month_day)
  end

  it "accepts for_dates without periodicity" do
    result = described_class.new.call(title: "Dates", scheduled_at: scheduled_at, for_dates: [ 2.days.from_now.to_date.iso8601 ])

    expect(result).to be_success
  end

  it "requires dates for for_dates periodicity" do
    result = described_class.new.call(title: "Dates", periodicity: "for_dates", scheduled_at: scheduled_at)

    expect(result).to be_failure
    expect(result.errors.to_h.keys).to include(:for_dates)
  end

  it "rejects unknown tags" do
    result = described_class.new.call(title: "Tagged", periodicity: "daily", scheduled_at: scheduled_at, ndays: 1, tags: [ "missing" ])

    expect(result).to be_failure
    expect(result.errors.to_h.keys).to include(:tags)
  end
end

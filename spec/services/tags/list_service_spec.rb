require "rails_helper"

RSpec.describe Tags::ListService do
  subject(:call_service) { described_class.call }

  let!(:calls_tag) { create(:tag, name: "calls") }
  let!(:reports_tag) { create(:tag, name: "reports") }

  it "returns tags ordered by name" do
    expect(call_service).to include(success: true)
    expect(call_service[:tags].pluck(:id)).to eq([ calls_tag.id, reports_tag.id ])
  end
end

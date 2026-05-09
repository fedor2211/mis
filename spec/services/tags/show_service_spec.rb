require "rails_helper"

RSpec.describe Tags::ShowService do
  subject(:call_service) { described_class.call(tag.id) }

  let(:tag) { create(:tag, name: "reports") }

  it "returns a tag" do
    expect(call_service).to include(success: true, tag: tag)
  end
end

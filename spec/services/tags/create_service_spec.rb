require "rails_helper"

RSpec.describe Tags::CreateService do
  subject(:call_service) { described_class.call(attributes) }

  let(:attributes) { { name: "Urgent" } }

  it "creates a tag" do
    result = nil

    expect { result = call_service }.to change(Tag, :count).by(1)
    expect(result[:tag]).to have_attributes(name: "urgent", persistent: false)
  end

  context "with invalid attributes" do
    let(:attributes) { { name: "" } }

    it "returns validation errors" do
      expect(call_service).to include(success: false)
      expect(call_service[:errors].keys).to include(:name)
    end
  end

  context "with a duplicate name" do
    let!(:tag) { create(:tag, name: "urgent") }

    it "returns validation errors" do
      expect(call_service).to include(success: false)
      expect(call_service[:errors]).to include(name: [ "has already been taken" ])
    end
  end
end

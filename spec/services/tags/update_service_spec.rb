require "rails_helper"

RSpec.describe Tags::UpdateService do
  subject(:call_service) { described_class.call(tag.id, attributes) }

  let(:tag) { create(:tag, name: "initial") }
  let(:attributes) { { name: "Updated" } }

  it "updates a tag" do
    expect(call_service).to include(success: true)
    expect(tag.reload.name).to eq("updated")
  end

  context "with invalid attributes" do
    let(:attributes) { { name: "" } }

    it "returns validation errors" do
      expect(call_service).to include(success: false)
      expect(call_service[:errors].keys).to include(:name)
    end
  end

  context "with a duplicate name" do
    let!(:existing_tag) { create(:tag, name: "updated") }

    it "returns validation errors" do
      expect(call_service).to include(success: false)
      expect(call_service[:errors]).to include(name: [ "has already been taken" ])
    end
  end

  context "with a persistent tag" do
    let(:tag) { create(:tag, name: "reports", persistent: true) }

    it "does not update the tag" do
      expect(call_service).to include(success: false, errors: [ "cannot be changed" ])
      expect(tag.reload.name).to eq("reports")
    end
  end
end

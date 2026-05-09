require "rails_helper"

RSpec.describe Tags::DestroyService do
  subject(:call_service) { described_class.call(tag.id) }

  context "with a regular tag" do
    let!(:tag) { create(:tag, name: "remove-me") }

    it "destroys the tag" do
      result = nil

      expect { result = call_service }.to change(Tag, :count).by(-1)
      expect(result).to include(success: true)
    end
  end

  context "with a persistent tag" do
    let!(:tag) { create(:tag, name: "reports", persistent: true) }

    it "does not destroy the tag" do
      expect { call_service }.not_to change(Tag, :count)
      expect(call_service).to include(success: false, errors: [ "cannot be deleted" ])
    end
  end
end

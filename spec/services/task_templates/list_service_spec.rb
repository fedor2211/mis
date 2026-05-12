require "rails_helper"

RSpec.describe TaskTemplates::ListService do
  subject(:call_service) { described_class.call(params) }

  let(:params) { {} }

  let!(:older_template) { create(:task_template, title: "Older template") }
  let!(:newer_template) { create(:task_template, title: "Newer template") }

  before do
    older_template.update_columns(created_at: Time.zone.parse("2026-05-08 12:00:00"))
    newer_template.update_columns(created_at: Time.zone.parse("2026-05-09 12:00:00"))
  end

  it "returns task templates ordered by newest first" do
    expect(call_service).to include(success: true)
    expect(call_service[:task_templates].limit_value).to eq(100)
    expect(call_service[:task_templates].offset_value).to eq(0)
    expect(call_service[:task_templates].pluck(:id)).to eq([ newer_template.id, older_template.id ])
  end

  context "with pagination" do
    let(:params) { { page: 2, per_page: 1 } }

    it "returns the requested page" do
      expect(call_service[:task_templates]).to contain_exactly(older_template)
    end
  end

  context "with invalid pagination" do
    let(:params) { { page: 0, per_page: 0 } }

    it "returns validation errors" do
      expect(call_service).to include(success: false)
      expect(call_service[:errors].keys).to include(:page, :per_page)
    end
  end
end

require "rails_helper"

RSpec.describe TaskTemplates::ListService do
  subject(:call_service) { described_class.call }

  let!(:older_template) { create(:task_template, title: "Older template") }
  let!(:newer_template) { create(:task_template, title: "Newer template") }

  before do
    older_template.update_columns(created_at: Time.zone.parse("2026-05-08 12:00:00"))
    newer_template.update_columns(created_at: Time.zone.parse("2026-05-09 12:00:00"))
  end

  it "returns task templates ordered by newest first" do
    expect(call_service).to include(success: true)
    expect(call_service[:task_templates].pluck(:id)).to eq([ newer_template.id, older_template.id ])
  end
end

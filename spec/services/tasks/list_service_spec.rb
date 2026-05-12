require "rails_helper"

RSpec.describe Tasks::ListService do
  subject(:call_service) { described_class.call(filters) }

  let(:filters) { {} }

  let(:reports_tag) { create(:tag, name: "reports") }
  let(:calls_tag) { create(:tag, name: "calls") }

  let!(:older_task) { create(:task, title: "Older task") }
  let!(:newer_task) { create(:task, title: "Newer task") }

  before do
    older_task.update_columns(created_at: Time.zone.parse("2026-05-08 12:00:00"))
    newer_task.update_columns(created_at: Time.zone.parse("2026-05-09 12:00:00"))
  end

  it "returns tasks ordered by newest first" do
    expect(call_service).to include(success: true)
    expect(call_service[:tasks].limit_value).to eq(100)
    expect(call_service[:tasks].offset_value).to eq(0)
    expect(call_service[:tasks].pluck(:id)).to eq([ newer_task.id, older_task.id ])
  end

  context "with pagination" do
    let(:filters) { { page: 2, per_page: 1 } }

    it "returns the requested page" do
      expect(call_service[:tasks]).to contain_exactly(older_task)
    end
  end

  context "with status and scheduled_at filters" do
    let(:filters) { { status: "completed", scheduled_at: "2026-05-09" } }
    let!(:matching_task) do
      create(:task, title: "Matching task", status: :completed, scheduled_at: "2026-05-09T08:00:00Z")
    end
    let!(:different_status_task) do
      create(:task, title: "Different status", status: :new, scheduled_at: "2026-05-09T09:00:00Z")
    end

    it "returns matching tasks" do
      expect(call_service[:tasks]).to contain_exactly(matching_task)
    end
  end

  context "with created_at filter" do
    let(:filters) { { created_at: "2026-05-09" } }

    it "returns tasks created on that date" do
      expect(call_service[:tasks]).to contain_exactly(newer_task)
    end
  end

  context "with tags filter" do
    let(:filters) { { tags: [ "reports" ] } }
    let!(:matching_task) { create(:task, title: "Tagged task", tags: [ reports_tag ]) }
    let!(:different_task) { create(:task, title: "Other tagged task", tags: [ calls_tag ]) }

    it "returns tasks with matching tags" do
      expect(call_service[:tasks]).to contain_exactly(matching_task)
    end
  end

  context "with invalid filters" do
    let(:filters) { { status: "unknown" } }

    it "returns validation errors" do
      expect(call_service).to include(success: false)
      expect(call_service[:errors].keys).to include(:status)
    end
  end

  context "with invalid pagination" do
    let(:filters) { { page: 0, per_page: 0 } }

    it "returns validation errors" do
      expect(call_service).to include(success: false)
      expect(call_service[:errors].keys).to include(:page, :per_page)
    end
  end
end

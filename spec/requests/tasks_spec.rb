require "rails_helper"

RSpec.describe "Tasks API" do
  let(:headers) { { "ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json" } }
  let(:json) { JSON.parse(response.body) }
  let(:scheduled_at) { "2026-05-09T10:00:00Z" }

  describe "POST /tasks" do
    subject(:perform_request) do
      post "/tasks", params: {
        task: {
          title: "Check patient chart",
          description: "Review current medications",
          scheduled_at: scheduled_at,
          tags: [ "reports" ]
        }
      }.to_json, headers: headers
    end

    let!(:tag) { create(:tag, name: "reports") }

    it "creates a task and returns the status and tags" do
      perform_request

      expect(response).to have_http_status(:created)
      expect(json.fetch("task")).to include(
        "title" => "Check patient chart",
        "description" => "Review current medications",
        "status" => "new",
        "tags" => [ "reports" ]
      )
    end
  end

  describe "GET /tasks/:id" do
    subject(:perform_request) { get "/tasks/#{task.id}", headers: headers }

    let(:task) { create(:task, title: "Call patient", status: :in_progress, tags: [ tag ]) }
    let(:tag) { create(:tag, name: "calls") }

    it "returns a task" do
      perform_request

      expect(response).to have_http_status(:ok)
      expect(json.fetch("task")).to include(
        "id" => task.id,
        "title" => "Call patient",
        "status" => "in_progress",
        "tags" => [ "calls" ]
      )
    end
  end

  describe "GET /tasks" do
    context "with scheduled_at and status filters" do
      subject(:perform_request) do
        get "/tasks", params: { scheduled_at: "2026-05-09", status: "completed" }, headers: headers
      end

      let!(:matching_task) do
        create(:task, title: "Prepare discharge", status: :completed, scheduled_at: "2026-05-09T08:00:00Z")
      end
      let!(:different_date_task) do
        create(:task, title: "Different date", status: :completed, scheduled_at: "2026-05-10T08:00:00Z")
      end
      let!(:different_status_task) do
        create(:task, title: "Different status", status: :new, scheduled_at: "2026-05-09T09:00:00Z")
      end

      it "filters tasks by scheduled_at date and status" do
        perform_request

        expect(response).to have_http_status(:ok)
        expect(json.fetch("tasks").pluck("id")).to contain_exactly(matching_task.id)
      end
    end

    context "with created_at filter" do
      subject(:perform_request) { get "/tasks", params: { created_at: "2026-05-09" }, headers: headers }

      let!(:matching_task) { create(:task, title: "Created today") }
      let!(:different_task) { create(:task, title: "Created yesterday") }

      before do
        different_task.update_columns(created_at: Time.zone.parse("2026-05-08 12:00:00"))
        matching_task.update_columns(created_at: Time.zone.parse("2026-05-09 12:00:00"))
      end

      it "filters tasks by created_at date" do
        perform_request

        expect(response).to have_http_status(:ok)
        expect(json.fetch("tasks").pluck("id")).to contain_exactly(matching_task.id)
      end
    end

    context "with tags filter" do
      subject(:perform_request) { get "/tasks", params: { tags: [ "reports" ] }, headers: headers }

      let(:tag) { create(:tag, name: "reports") }
      let(:other_tag) { create(:tag, name: "calls") }
      let!(:matching_task) { create(:task, title: "Tagged task", tags: [ tag ]) }
      let!(:different_task) { create(:task, title: "Other tagged task", tags: [ other_tag ]) }

      it "filters tasks by assigned tags" do
        perform_request

        expect(response).to have_http_status(:ok)
        expect(json.fetch("tasks").pluck("id")).to contain_exactly(matching_task.id)
      end
    end
  end

  describe "PATCH /tasks/:id" do
    subject(:perform_request) do
      patch "/tasks/#{task.id}", params: {
        task: { title: "Updated title", status: "cancelled", tags: [ "reports" ] }
      }.to_json, headers: headers
    end

    let(:task) { create(:task, title: "Initial title", tags: [ old_tag ]) }
    let(:old_tag) { create(:tag, name: "calls") }
    let!(:new_tag) { create(:tag, name: "reports") }

    it "updates a task" do
      perform_request

      expect(response).to have_http_status(:ok)
      expect(json.fetch("task")).to include(
        "title" => "Updated title",
        "status" => "cancelled",
        "tags" => [ "reports" ]
      )
    end
  end

  describe "DELETE /tasks/:id" do
    subject(:perform_request) { delete "/tasks/#{task.id}", headers: headers }

    let!(:task) { create(:task, title: "Remove task") }

    it "destroys a task and returns json" do
      expect { perform_request }.to change(Task, :count).by(-1)

      expect(response).to have_http_status(:ok)
      expect(json.fetch("task")).to include("id" => task.id)
    end
  end
end

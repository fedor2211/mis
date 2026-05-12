require "rails_helper"

RSpec.describe "Tasks API" do
  let(:headers) { { "ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json" } }
  let(:json) { JSON.parse(response.body) }
  let(:scheduled_at) { 1.day.from_now.iso8601 }

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

    context "with pagination" do
      subject(:perform_request) { get "/tasks", params: { page: 2, per_page: 1 }, headers: headers }

      let!(:older_task) { create(:task, title: "Older task") }
      let!(:newer_task) { create(:task, title: "Newer task") }

      before do
        older_task.update_columns(created_at: Time.zone.parse("2026-05-08 12:00:00"))
        newer_task.update_columns(created_at: Time.zone.parse("2026-05-09 12:00:00"))
      end

      it "returns the requested page" do
        perform_request

        expect(response).to have_http_status(:ok)
        expect(json.fetch("tasks").pluck("id")).to eq([ older_task.id ])
      end
    end
  end

  describe "PATCH /tasks/:id" do
    subject(:perform_request) do
      patch "/tasks/#{task.id}", params: {
        task: task_params
      }.to_json, headers: headers
    end

    let(:task) { create(:task, title: "Initial title", tags: [ old_tag ]) }
    let(:task_params) { { title: "Updated title", status: "cancelled", tags: [ "reports" ] } }
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

    context "with a duplicate template scheduled_at" do
      let(:task_template) { create(:task_template) }
      let(:current_scheduled_at) { 2.days.from_now.change(usec: 0) }
      let(:duplicate_scheduled_at) { 3.days.from_now.change(usec: 0) }
      let(:task) { create(:task, task_template: task_template, scheduled_at: current_scheduled_at) }
      let!(:duplicate_task) { create(:task, task_template: task_template, scheduled_at: duplicate_scheduled_at) }
      let(:task_params) { { scheduled_at: duplicate_scheduled_at.iso8601 } }

      it "does not update the task" do
        perform_request

        expect(response).to have_http_status(:unprocessable_content)
        expect(json.fetch("errors").fetch("scheduled_at")).to include("has already been taken for this task template")
      end
    end

    context "with a templated task scheduled after the nearest future task" do
      let(:task_template) { create(:task_template) }
      let(:current_scheduled_at) { 2.days.from_now.change(usec: 0) }
      let(:nearest_future_scheduled_at) { 3.days.from_now.change(usec: 0) }
      let(:task) { create(:task, task_template: task_template, scheduled_at: current_scheduled_at) }
      let!(:nearest_future_task) { create(:task, task_template: task_template, scheduled_at: nearest_future_scheduled_at) }
      let(:task_params) { { scheduled_at: (nearest_future_scheduled_at + 1.hour).iso8601 } }

      it "does not update the task" do
        perform_request

        expect(response).to have_http_status(:unprocessable_content)
        expect(json.fetch("errors").fetch("scheduled_at")).to include(
          "must not be greater than nearest future task from same template"
        )
      end
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

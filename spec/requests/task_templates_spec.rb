require "rails_helper"

RSpec.describe "TaskTemplates API" do
  let(:headers) { { "ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json" } }
  let(:json) { JSON.parse(response.body) }

  describe "POST /task_templates" do
    subject(:perform_request) do
      post "/task_templates", params: {
        task_template: {
          title: "Review labs",
          description: "Morning review",
          scheduled_at: 1.day.from_now.iso8601,
          tags: [ "reports" ],
          **periodicity_params
        }
      }.to_json, headers: headers
    end

    let!(:tag) { create(:tag, name: "reports") }
    let(:periodicity_params) { { periodicity: "daily", ndays: 1 } }

    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it "creates a template and enqueues task generation" do
      expect { perform_request }.to have_enqueued_job(GenerateTaskTemplateTasksJob)

      expect(response).to have_http_status(:created)
      expect(json.fetch("task_template")).to include(
        "title" => "Review labs",
        "periodicity" => "daily",
        "tags" => [ "reports" ]
      )
    end

    context "with certain dates" do
      let(:for_date) { 2.days.from_now.to_date }
      let(:periodicity_params) { { periodicity: "for_dates", for_dates: [ for_date.iso8601 ] } }

      it "persists template dates and enqueues task generation" do
        expect { perform_request }.to change(TaskTemplate, :count).by(1).and have_enqueued_job(GenerateTaskTemplateTasksJob)

        expect(response).to have_http_status(:created)
        expect(json.fetch("task_template")).to include(
          "title" => "Review labs",
          "periodicity" => "for_dates",
          "dates" => [ for_date.iso8601 ],
          "tags" => [ "reports" ]
        )
      end
    end
  end

  describe "GET /task_templates" do
    subject(:perform_request) { get "/task_templates", headers: headers }

    let!(:task_template) { create(:task_template, title: "Template") }

    it "lists task templates" do
      perform_request

      expect(response).to have_http_status(:ok)
      expect(json.fetch("task_templates").pluck("id")).to include(task_template.id)
    end
  end

  describe "GET /task_templates/:id" do
    subject(:perform_request) { get "/task_templates/#{task_template.id}", headers: headers }

    let(:tag) { create(:tag, name: "reports") }
    let(:task_template) { create(:task_template, title: "Template", tags: [ tag ]) }

    it "returns a task template" do
      perform_request

      expect(response).to have_http_status(:ok)
      expect(json.fetch("task_template")).to include(
        "id" => task_template.id,
        "title" => "Template",
        "tags" => [ "reports" ]
      )
    end
  end

  describe "DELETE /task_templates/:id" do
    subject(:perform_request) { delete "/task_templates/#{task_template.id}", headers: headers }

    let!(:task_template) { create(:task_template, title: "Template") }
    let!(:future_task) { create(:task, task_template: task_template, scheduled_at: 1.day.from_now) }

    it "cancels future tasks and destroys a task template" do
      expect { perform_request }.to change(TaskTemplate, :count).by(-1)
      expect(response).to have_http_status(:ok)
      expect(future_task.reload.status).to eq("cancelled")
    end
  end
end

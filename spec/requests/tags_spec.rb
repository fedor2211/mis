require "rails_helper"

RSpec.describe "Tags API" do
  let(:headers) { { "ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json" } }
  let(:json) { JSON.parse(response.body) }

  describe "POST /tags" do
    subject(:perform_request) do
      post "/tags", params: { tag: { name: "Urgent" } }.to_json, headers: headers
    end

    it "creates a tag" do
      perform_request

      expect(response).to have_http_status(:created)
      expect(json.fetch("tag")).to include(
        "name" => "urgent",
        "persistent" => false
      )
    end

    context "when a tag with the downcased name already exists" do
      let!(:existing_tag) { create(:tag, name: "urgent") }

      it "does not create a duplicate" do
        perform_request

        expect(response).to have_http_status(:unprocessable_content)
        expect(json.fetch("errors")).to include("name" => [ "has already been taken" ])
      end
    end
  end

  describe "GET /tags/:id" do
    subject(:perform_request) { get "/tags/#{tag.id}", headers: headers }

    let(:tag) { create(:tag, name: "reports") }

    it "returns a tag" do
      perform_request

      expect(response).to have_http_status(:ok)
      expect(json.fetch("tag")).to include(
        "id" => tag.id,
        "name" => "reports"
      )
    end
  end

  describe "GET /tags" do
    subject(:perform_request) { get "/tags", headers: headers }

    let!(:first_tag) { create(:tag, name: "calls") }
    let!(:second_tag) { create(:tag, name: "reports") }

    it "lists tags ordered by name" do
      perform_request

      expect(response).to have_http_status(:ok)
      expect(json.fetch("tags").pluck("id")).to eq([ first_tag.id, second_tag.id ])
    end
  end

  describe "PATCH /tags/:id" do
    subject(:perform_request) do
      patch "/tags/#{tag.id}", params: { tag: { name: "Updated" } }.to_json, headers: headers
    end

    context "with a regular tag" do
      let(:tag) { create(:tag, name: "initial") }

      it "updates a tag" do
        perform_request

        expect(response).to have_http_status(:ok)
        expect(json.fetch("tag")).to include("name" => "updated")
      end

      context "when a tag with the downcased name already exists" do
        let!(:existing_tag) { create(:tag, name: "updated") }

        it "does not update to a duplicate name" do
          perform_request

          expect(response).to have_http_status(:unprocessable_content)
          expect(json.fetch("errors")).to include("name" => [ "has already been taken" ])
        end
      end
    end

    context "with a persistent tag" do
      let(:tag) { create(:tag, name: "reports", persistent: true) }

      it "does not update the tag" do
        perform_request

        expect(response).to have_http_status(:unprocessable_content)
        expect(json.fetch("errors")).to include("cannot be changed")
      end
    end
  end

  describe "DELETE /tags/:id" do
    subject(:perform_request) { delete "/tags/#{tag.id}", headers: headers }

    context "with a regular tag" do
      let!(:tag) { create(:tag, name: "remove-me") }

      it "destroys a tag" do
        expect { perform_request }.to change(Tag, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(json.fetch("tag")).to include("id" => tag.id)
      end
    end

    context "with a persistent tag" do
      let!(:tag) { create(:tag, name: "reports", persistent: true) }

      it "does not destroy the tag" do
        expect { perform_request }.not_to change(Tag, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(json.fetch("errors")).to include("cannot be deleted")
      end
    end
  end
end

class TaskSerializer < ApplicationSerializer
  attributes :id, :title, :description, :scheduled_at, :status, :created_at, :updated_at
end

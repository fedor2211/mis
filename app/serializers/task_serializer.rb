class TaskSerializer < ApplicationSerializer
  attributes :id, :title, :description, :scheduled_at, :status, :tags, :created_at, :updated_at

  def tags
    object.tags.order(:name).pluck(:name)
  end
end

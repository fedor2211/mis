class TaskSerializer < ApplicationSerializer
  attributes :id, :title, :description, :scheduled_at, :status, :task_template_id, :tags, :created_at, :updated_at

  def tags
    object.tags.order(:name).pluck(:name)
  end
end

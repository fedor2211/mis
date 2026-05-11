class TaskTemplateSerializer < ApplicationSerializer
  attributes :id, :title, :description, :periodicity, :scheduled_at, :ndays, :month_day, :active_until, :dates, :tags,
              :created_at, :updated_at

  def tags
    object.tags.pluck(:name)
  end
end

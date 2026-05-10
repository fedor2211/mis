class TaskTemplateSerializer < ApplicationSerializer
  attributes :id, :title, :description, :periodicity, :scheduled_at, :ndays, :month_day, :active_until, :dates, :tags,
              :created_at, :updated_at

  def tags
    if object.persisted?
      object.tags.order(:name).pluck(:name)
    else
      object.tags.sort_by(&:name).map(&:name)
    end
  end
end

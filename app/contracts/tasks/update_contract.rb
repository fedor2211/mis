module Tasks
  class UpdateContract < ApplicationContract
    option :task, optional: true

    params do
      optional(:title).filled(:string)
      optional(:description).value(:string)
      optional(:scheduled_at).filled(:date_time)
      optional(:status).filled(:string, included_in?: Task.statuses.keys)
      optional(:tags).array(:string)
    end

    rule(:tags) do
      validate_tag_names(key, value) if key?
    end

    rule(:scheduled_at) do
      next unless key?

      validate_future_datetime(key, value)
      next unless task&.task_template_id

      scheduled_at = value.to_time

      if duplicate_template_scheduled_at?(scheduled_at)
        key.failure("has already been taken for this task template")
      end

      next_task = nearest_future_template_task
      if next_task && scheduled_at > next_task.scheduled_at
        key.failure("must not be greater than nearest future task from same template")
      end
    end

    private

    def duplicate_template_scheduled_at?(scheduled_at)
      Task.where(task_template_id: task.task_template_id, scheduled_at: scheduled_at)
        .where.not(id: task.id)
        .exists?
    end

    def nearest_future_template_task
      Task.where(task_template_id: task.task_template_id)
        .where.not(id: task.id)
        .where("scheduled_at > ?", task.scheduled_at)
        .order(:scheduled_at)
        .first
    end
  end
end

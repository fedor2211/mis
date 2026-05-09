module Tasks
  class ListService < ApplicationService
    def initialize(filters)
      @filters = filters
    end

    def call
      validation = ListContract.new.call(@filters)
      return { success: false, errors: validation.errors.to_h } if validation.failure?

      filters = validation.to_h
      tasks = Task.order(created_at: :desc)
      tasks = tasks.where(status: filters[:status]) if filters[:status]
      tasks = tasks.where(scheduled_at: filters[:scheduled_at].all_day) if filters[:scheduled_at]
      tasks = tasks.where(created_at: filters[:created_at].all_day) if filters[:created_at]
      tasks = tasks.joins(:tags).where(tags: { name: filters[:tags] }).distinct if filters[:tags]

      { success: true, tasks: tasks }
    end
  end
end

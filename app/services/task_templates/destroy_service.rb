module TaskTemplates
  class DestroyService < ApplicationService
    def initialize(id)
      @id = id
    end

    def call
      task_template = TaskTemplate.find(@id)

      TaskTemplate.transaction do
        task_template.tasks.where("scheduled_at > ?", Time.current).update_all(status: Task.statuses.fetch("cancelled"))
        task_template.destroy!
      end

      { success: true, task_template: task_template }
    end
  end
end

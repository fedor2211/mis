module TaskTemplates
  class ListService < ApplicationService
    def call
      { success: true, task_templates: TaskTemplate.order(created_at: :desc) }
    end
  end
end

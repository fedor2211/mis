class GenerateTaskTemplateTasksJob < ApplicationJob
  queue_as :default

  def perform(task_template_id:, month: Date.current)
    task_template = TaskTemplate.find_by(id: task_template_id)
    return unless task_template

    TaskTemplates::GenerateTasksService.call(template: task_template, month: month)
  end
end

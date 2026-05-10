class GenerateMonthlyTasksJob < ApplicationJob
  queue_as :default

  def perform(month = Date.current)
    month = month.to_date

    TaskTemplate.active_for_month(month).find_each do |template|
      TaskTemplates::GenerateTasksService.call(template: template, month: month)
    rescue StandardError => error
      Rails.logger.error(
        "Failed to generate monthly tasks: task_template_id=#{template.id} month=#{month} " \
        "error=#{error.class}: #{error.message}\n#{Array(error.backtrace).first(5).join("\n")}"
      )
    end
  end
end

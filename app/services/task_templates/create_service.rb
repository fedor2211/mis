module TaskTemplates
  class CreateService < ApplicationService
    def initialize(attributes)
      @attributes = attributes
    end

    def call
      validation = CreateContract.new.call(@attributes)
      return { success: false, errors: validation.errors.to_h } if validation.failure?

      attributes = validation.to_h
      tag_names = attributes.delete(:tags)
      for_dates = attributes.delete(:for_dates)
      attributes[:dates] = for_dates if for_dates.present? && attributes[:periodicity] == "for_dates"

      task_template = TaskTemplate.transaction do
        TaskTemplate.create!(attributes).tap do |template|
          assign_tags(template, tag_names) if tag_names
        end
      end

      GenerateTaskTemplateTasksJob.perform_later(task_template_id: task_template.id, month: Date.current)

      { success: true, task_template: task_template }
    end

    private

    def assign_tags(task_template, names)
      task_template.tags = Tag.where(name: names)
    end
  end
end

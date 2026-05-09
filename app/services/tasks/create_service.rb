module Tasks
  class CreateService < ApplicationService
    def initialize(attributes)
      @attributes = attributes
    end

    def call
      validation = CreateContract.new.call(@attributes)
      return { success: false, errors: validation.errors.to_h } if validation.failure?

      attributes = validation.to_h
      tag_names = attributes.delete(:tags)
      task = Task.transaction do
        Task.create!(attributes).tap do |created_task|
          assign_tags(created_task, tag_names) if tag_names
        end
      end

      { success: true, task: task }
    end

    private

    def assign_tags(task, names)
      task.tags = Tag.where(name: names)
    end
  end
end

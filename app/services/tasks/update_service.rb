module Tasks
  class UpdateService < ApplicationService
    def initialize(id, attributes)
      @id = id
      @attributes = attributes
    end

    def call
      validation = UpdateContract.new.call(@attributes)
      return { success: false, errors: validation.errors.to_h } if validation.failure?

      attributes = validation.to_h
      tag_names = attributes.delete(:tags)
      task = Task.find(@id)
      Task.transaction do
        task.update!(attributes)
        assign_tags(task, tag_names) if tag_names
      end

      { success: true, task: task }
    end

    private

    def assign_tags(task, names)
      task.tags = Tag.where(name: names)
    end
  end
end

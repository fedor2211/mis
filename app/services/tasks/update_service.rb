module Tasks
  class UpdateService < ApplicationService
    def initialize(id, attributes)
      @id = id
      @attributes = attributes
    end

    def call
      validation = UpdateContract.new.call(@attributes)
      return { success: false, errors: validation.errors.to_h } if validation.failure?

      task = Task.find(@id)
      task.update!(validation.to_h)

      { success: true, task: task }
    end
  end
end

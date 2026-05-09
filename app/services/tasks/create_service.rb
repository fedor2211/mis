module Tasks
  class CreateService < ApplicationService
    def initialize(attributes)
      @attributes = attributes
    end

    def call
      validation = CreateContract.new.call(@attributes)
      return { success: false, errors: validation.errors.to_h } if validation.failure?

      task = Task.create!(validation.to_h)

      { success: true, task: task }
    end
  end
end

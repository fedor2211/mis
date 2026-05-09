module Tasks
  class DestroyService < ApplicationService
    def initialize(id)
      @id = id
    end

    def call
      task = Task.find(@id)
      task.destroy!

      { success: true, task: task }
    end
  end
end

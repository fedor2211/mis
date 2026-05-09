module Tasks
  class ShowService < ApplicationService
    def initialize(id)
      @id = id
    end

    def call
      { success: true, task: Task.find(@id) }
    end
  end
end

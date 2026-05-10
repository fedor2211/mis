module TaskTemplates
  class ShowService < ApplicationService
    def initialize(id)
      @id = id
    end

    def call
      { success: true, task_template: TaskTemplate.find(@id) }
    end
  end
end

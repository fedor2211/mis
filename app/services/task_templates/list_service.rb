module TaskTemplates
  class ListService < ApplicationService
    def initialize(params = {})
      @params = params
    end

    def call
      validation = ListContract.new.call(@params)
      return { success: false, errors: validation.errors.to_h } if validation.failure?

      params = validation.to_h
      task_templates = TaskTemplate.order(created_at: :desc).includes(:tags)
      task_templates = task_templates.limit(per_page(params)).offset(offset(params))

      { success: true, task_templates: task_templates }
    end

    private

    def page(params)
      params.fetch(:page, 1)
    end

    def per_page(params)
      params.fetch(:per_page, 100)
    end

    def offset(params)
      (page(params) - 1) * per_page(params)
    end
  end
end

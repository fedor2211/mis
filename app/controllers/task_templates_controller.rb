class TaskTemplatesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::ParameterMissing, with: :render_parameter_missing

  def index
    result = TaskTemplates::ListService.call(list_params.to_h)
    return render_errors(result) unless result[:success]

    render json: { task_templates: serialize_collection(result[:task_templates], TaskTemplateSerializer) }
  end

  def show
    result = TaskTemplates::ShowService.call(params[:id])

    render json: { task_template: serialize_task_template(result[:task_template]) }
  end

  def create
    result = TaskTemplates::CreateService.call(task_template_params.to_h)
    return render_errors(result) unless result[:success]

    render json: { task_template: serialize_task_template(result[:task_template]) }, status: :created
  end

  def destroy
    result = TaskTemplates::DestroyService.call(params[:id])

    render json: { task_template: serialize_task_template(result[:task_template]) }
  end

  private

  def task_template_params
    params.require(:task_template).permit(
      :title,
      :description,
      :periodicity,
      :scheduled_at,
      :ndays,
      :month_day,
      :active_until,
      tags: [],
      for_dates: []
    )
  end

  def list_params
    params.permit(:page, :per_page)
  end

  def serialize_task_template(task_template)
    TaskTemplateSerializer.new(task_template).as_json
  end

  def render_not_found
    render json: { errors: { task_template: [ "not found" ] } }, status: :not_found
  end

  def render_parameter_missing(error)
    render json: { errors: { error.param => [ "is required" ] } }, status: :bad_request
  end
end

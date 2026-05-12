class TasksController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::ParameterMissing, with: :render_parameter_missing

  def index
    result = Tasks::ListService.call(list_params.to_h)
    return render_errors(result) unless result[:success]

    render json: { tasks: serialize_collection(result[:tasks], TaskSerializer) }
  end

  def show
    result = Tasks::ShowService.call(params[:id])

    render json: { task: serialize_task(result[:task]) }
  end

  def create
    result = Tasks::CreateService.call(task_params.to_h)
    return render_errors(result) unless result[:success]

    render json: { task: serialize_task(result[:task]) }, status: :created
  end

  def update
    result = Tasks::UpdateService.call(params[:id], task_params.to_h)
    return render_errors(result) unless result[:success]

    render json: { task: serialize_task(result[:task]) }
  end

  def destroy
    result = Tasks::DestroyService.call(params[:id])

    render json: { task: serialize_task(result[:task]) }
  end

  private

  def task_params
    params.require(:task).permit(
      :title,
      :description,
      :scheduled_at,
      :status,
      tags: []
    )
  end

  def list_params
    params.permit(:status, :scheduled_at, :created_at, :page, :per_page, tags: [])
  end

  def serialize_task(task)
    TaskSerializer.new(task).as_json
  end

  def render_not_found
    render json: { errors: { task: [ "not found" ] } }, status: :not_found
  end

  def render_parameter_missing(error)
    render json: { errors: { error.param => [ "is required" ] } }, status: :bad_request
  end
end

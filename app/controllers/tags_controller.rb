class TagsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::ParameterMissing, with: :render_parameter_missing

  def index
    result = Tags::ListService.call

    render json: { tags: serialize_collection(result[:tags], TagSerializer) }
  end

  def show
    result = Tags::ShowService.call(params[:id])

    render json: { tag: serialize_tag(result[:tag]) }
  end

  def create
    result = Tags::CreateService.call(tag_params.to_h)
    return render_errors(result) unless result[:success]

    render json: { tag: serialize_tag(result[:tag]) }, status: :created
  end

  def update
    result = Tags::UpdateService.call(params[:id], tag_params.to_h)
    return render_errors(result) unless result[:success]

    render json: { tag: serialize_tag(result[:tag]) }
  end

  def destroy
    result = Tags::DestroyService.call(params[:id])
    return render_errors(result) unless result[:success]

    render json: { tag: serialize_tag(result[:tag]) }
  end

  private

  def tag_params
    params.require(:tag).permit(:name)
  end

  def serialize_tag(tag)
    TagSerializer.new(tag).as_json
  end

  def render_not_found
    render json: { errors: { tag: [ "not found" ] } }, status: :not_found
  end

  def render_parameter_missing(error)
    render json: { errors: { error.param => [ "is required" ] } }, status: :bad_request
  end
end

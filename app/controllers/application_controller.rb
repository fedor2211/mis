class ApplicationController < ActionController::API
  def serialize_collection(collection, serializer, **options)
    ActiveModel::Serializer::CollectionSerializer.new(collection, serializer:, **options).as_json
  end

  def render_errors(result)
    render json: { errors: result[:errors] }, status: :unprocessable_entity
  end
end

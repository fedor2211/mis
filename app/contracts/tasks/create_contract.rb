module Tasks
  class CreateContract < ApplicationContract
    params do
      required(:title).filled(:string)
      optional(:description).value(:string)
      required(:scheduled_at).filled(:date_time)
      optional(:status).filled(:string, included_in?: Task.statuses.keys)
      optional(:tags).array(:string)
    end

    rule(:tags) do
      validate_tag_names(key, value) if key?
    end

    rule(:scheduled_at) do
      validate_future_datetime(key, value)
    end
  end
end

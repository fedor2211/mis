module Tasks
  class ListContract < ApplicationContract
    params do
      optional(:status).filled(:string, included_in?: Task.statuses.keys)
      optional(:scheduled_at).filled(:date)
      optional(:created_at).filled(:date)
      optional(:tags).array(:string)
    end

    rule(:tags) do
      validate_tag_names(key, value) if key?
    end
  end
end

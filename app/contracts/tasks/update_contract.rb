module Tasks
  class UpdateContract < Dry::Validation::Contract
    params do
      optional(:title).filled(:string)
      optional(:description).value(:string)
      optional(:scheduled_at).filled(:date_time)
      optional(:status).filled(:string, included_in?: Task.statuses.keys)
    end
  end
end

module Tasks
  class ListContract < Dry::Validation::Contract
    params do
      optional(:status).filled(:string, included_in?: Task.statuses.keys)
      optional(:scheduled_at).filled(:date)
      optional(:created_at).filled(:date)
    end
  end
end

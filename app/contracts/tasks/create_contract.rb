module Tasks
  class CreateContract < Dry::Validation::Contract
    params do
      required(:title).filled(:string)
      optional(:description).value(:string)
      required(:scheduled_at).filled(:date_time)
      optional(:status).filled(:string, included_in?: Task.statuses.keys)
    end
  end
end

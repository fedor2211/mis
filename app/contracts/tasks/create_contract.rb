module Tasks
  class CreateContract < Dry::Validation::Contract
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
      key.failure("must be greater than current datetime") if value && value.to_time <= Time.current
    end

    private

    def validate_tag_names(key, names)
      key.failure("must not include blank names") if names.any?(&:blank?)

      missing_names = names.uniq - Tag.where(name: names).pluck(:name)
      key.failure("contains unknown tags: #{missing_names.join(', ')}") if missing_names.any?
    end
  end
end

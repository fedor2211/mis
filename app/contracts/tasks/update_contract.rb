module Tasks
  class UpdateContract < Dry::Validation::Contract
    params do
      optional(:title).filled(:string)
      optional(:description).value(:string)
      optional(:scheduled_at).filled(:date_time)
      optional(:status).filled(:string, included_in?: Task.statuses.keys)
      optional(:tags).array(:string)
    end

    rule(:tags) do
      validate_tag_names(key, value) if key?
    end

    private

    def validate_tag_names(key, names)
      key.failure("must not include blank names") if names.any?(&:blank?)

      missing_names = names.uniq - Tag.where(name: names).pluck(:name)
      key.failure("contains unknown tags: #{missing_names.join(', ')}") if missing_names.any?
    end
  end
end

module Tasks
  class ListContract < Dry::Validation::Contract
    params do
      optional(:status).filled(:string, included_in?: Task.statuses.keys)
      optional(:scheduled_at).filled(:date)
      optional(:created_at).filled(:date)
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

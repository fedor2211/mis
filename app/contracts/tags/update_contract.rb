module Tags
  class UpdateContract < Dry::Validation::Contract
    option :tag_id, optional: true

    params do
      optional(:name).filled(:string)
    end

    rule(:name) do
      next unless value

      relation = Tag.where(name: value.downcase)
      relation = relation.where.not(id: tag_id) if tag_id
      key.failure("has already been taken") if relation.exists?
    end
  end
end

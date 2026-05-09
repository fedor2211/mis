module Tags
  class CreateContract < Dry::Validation::Contract
    params do
      required(:name).filled(:string)
    end

    rule(:name) do
      key.failure("has already been taken") if Tag.exists?(name: value.downcase)
    end
  end
end

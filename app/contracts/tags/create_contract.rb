module Tags
  class CreateContract < ApplicationContract
    params do
      required(:name).filled(:string)
    end

    rule(:name) do
      key.failure("has already been taken") if tag_name_taken?(value)
    end
  end
end

module Tags
  class UpdateContract < ApplicationContract
    option :tag_id, optional: true

    params do
      optional(:name).filled(:string)
    end

    rule(:name) do
      next unless value

      key.failure("has already been taken") if tag_name_taken?(value, except_id: tag_id)
    end
  end
end

module TaskTemplates
  class ListContract < ApplicationContract
    params do
      optional(:page).filled(:integer)
      optional(:per_page).filled(:integer)
    end

    rule(:page) do
      key.failure("must be greater than 0") if key? && !positive?(value)
    end

    rule(:per_page) do
      key.failure("must be greater than 0") if key? && !positive?(value)
    end
  end
end

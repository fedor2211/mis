module Tags
  class CreateService < ApplicationService
    def initialize(attributes)
      @attributes = attributes
    end

    def call
      validation = CreateContract.new.call(@attributes)
      return { success: false, errors: validation.errors.to_h } if validation.failure?

      tag = Tag.create!(validation.to_h)

      { success: true, tag: tag }
    end
  end
end

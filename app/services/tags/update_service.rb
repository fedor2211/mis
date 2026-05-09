module Tags
  class UpdateService < ApplicationService
    def initialize(id, attributes)
      @id = id
      @attributes = attributes
    end

    def call
      tag = Tag.find(@id)
      return persistent_error if tag.persistent?

      validation = UpdateContract.new(tag_id: tag.id).call(@attributes)
      return { success: false, errors: validation.errors.to_h } if validation.failure?

      tag.update!(validation.to_h)

      { success: true, tag: tag }
    end

    private

    def persistent_error
      { success: false, errors: [ "cannot be changed" ] }
    end
  end
end

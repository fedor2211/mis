module Tags
  class DestroyService < ApplicationService
    def initialize(id)
      @id = id
    end

    def call
      tag = Tag.find(@id)
      return persistent_error if tag.persistent?

      tag.destroy!

      { success: true, tag: tag }
    end

    private

    def persistent_error
      { success: false, errors: [ "cannot be deleted" ] }
    end
  end
end

module Tags
  class ShowService < ApplicationService
    def initialize(id)
      @id = id
    end

    def call
      { success: true, tag: Tag.find(@id) }
    end
  end
end

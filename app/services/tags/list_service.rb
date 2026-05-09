module Tags
  class ListService < ApplicationService
    def call
      { success: true, tags: Tag.order(:name) }
    end
  end
end

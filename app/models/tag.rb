class Tag < ApplicationRecord
  SYSTEM_NAMES = %w[ reports operations calls ].freeze

  before_save :downcase_name

  private

  def downcase_name
    self.name = name.downcase if name.present?
  end
end

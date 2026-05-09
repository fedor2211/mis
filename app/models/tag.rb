class Tag < ApplicationRecord
  SYSTEM_NAMES = %w[ reports operations calls ].freeze

  has_many :task_tags, dependent: :destroy
  has_many :tasks, through: :task_tags

  before_save :downcase_name

  private

  def downcase_name
    self.name = name.downcase if name.present?
  end
end

class Tag < ApplicationRecord
  SYSTEM_NAMES = %w[ reports operations calls ].freeze

  has_many :task_tags, dependent: :destroy
  has_many :tasks, through: :task_tags
  has_many :task_template_tags, dependent: :destroy
  has_many :task_templates, through: :task_template_tags

  before_save :downcase_name

  private

  def downcase_name
    self.name = name.downcase if name.present?
  end
end

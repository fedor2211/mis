class TaskTemplate < ApplicationRecord
  has_many :tasks, dependent: :nullify
  has_many :task_template_tags, dependent: :destroy
  has_many :tags, through: :task_template_tags

  enum :periodicity, {
    daily: 0,
    monthly: 1,
    odd_days: 2,
    even_days: 3,
    for_dates: 4
  }, prefix: true

  scope :active_for_month, ->(month) {
    month = month.to_date
    recurring_templates = where.not(periodicity: periodicities.fetch("for_dates"))

    recurring_templates.where(active_until: nil).or(recurring_templates.where(active_until: month.beginning_of_month..))
  }
end

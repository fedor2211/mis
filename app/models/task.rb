class Task < ApplicationRecord
  belongs_to :task_template, optional: true

  has_many :task_tags, dependent: :destroy
  has_many :tags, through: :task_tags

  enum :status, {
    new: 0,
    in_progress: 1,
    completed: 2,
    cancelled: 3
  }, prefix: true
end

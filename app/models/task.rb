class Task < ApplicationRecord
  enum :status, {
    new: 0,
    in_progress: 1,
    completed: 2,
    cancelled: 3
  }, prefix: true
end

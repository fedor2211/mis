class TaskTemplateTag < ApplicationRecord
  belongs_to :task_template
  belongs_to :tag
end

class AddTaskTemplateToTasks < ActiveRecord::Migration[8.1]
  def change
    add_reference :tasks, :task_template, foreign_key: true
    add_index :tasks, [ :task_template_id, :scheduled_at ], unique: true, where: "task_template_id IS NOT NULL"
  end
end

class CreateTaskTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :task_templates do |t|
      t.string :title, null: false
      t.string :description, null: false, default: ""
      t.integer :periodicity, null: false
      t.datetime :scheduled_at, null: false
      t.integer :ndays
      t.integer :month_day
      t.date :active_until
      t.date :dates, array: true, null: false, default: []

      t.timestamps
    end

    add_index :task_templates, :periodicity
  end
end

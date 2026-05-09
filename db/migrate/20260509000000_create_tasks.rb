class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.string :description, null: false, default: ""
      t.datetime :scheduled_at, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :tasks, :scheduled_at
    add_index :tasks, :status
  end
end

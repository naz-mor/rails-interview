class AddTimestampsToTodoItems < ActiveRecord::Migration[7.0]
  def change
    add_timestamps :todo_items, null: true

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE todo_items
          SET created_at = COALESCE(completed_at, CURRENT_TIMESTAMP),
              updated_at = COALESCE(completed_at, CURRENT_TIMESTAMP)
        SQL
      end
    end

    change_column_null :todo_items, :created_at, false
    change_column_null :todo_items, :updated_at, false
  end
end

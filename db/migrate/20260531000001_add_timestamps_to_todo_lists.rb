class AddTimestampsToTodoLists < ActiveRecord::Migration[7.0]
  def change
    add_timestamps :todo_lists, null: true

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE todo_lists
          SET created_at = CURRENT_TIMESTAMP,
              updated_at = CURRENT_TIMESTAMP
        SQL
      end
    end

    change_column_null :todo_lists, :created_at, false
    change_column_null :todo_lists, :updated_at, false
  end
end

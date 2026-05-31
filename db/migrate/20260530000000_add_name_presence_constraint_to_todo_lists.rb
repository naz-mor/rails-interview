class AddNamePresenceConstraintToTodoLists < ActiveRecord::Migration[7.0]
  def up
    execute <<~SQL.squish
      UPDATE todo_lists
      SET name = 'Untitled Todo List ' || id
      WHERE name IS NULL OR length(trim(name)) = 0
    SQL

    add_check_constraint :todo_lists, "length(trim(name)) > 0", name: "todo_lists_name_presence"
  end

  def down
    remove_check_constraint :todo_lists, name: "todo_lists_name_presence"
  end
end

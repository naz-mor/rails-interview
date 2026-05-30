class AddUniqueIndexToTodoListsName < ActiveRecord::Migration[7.0]
  def change
    add_index :todo_lists, :name, unique: true
  end
end

class TodoItemsController < App::ApplicationController
  before_action :set_todo_list

  def create
    @todo_item = @todo_list.todo_items.build(todo_item_params)

    render :new, status: :unprocessable_entity unless @todo_item.save
  end

  def update
    @todo_item = @todo_list.todo_items.find(params.require(:id))
    @todo_item.update!(todo_item_params)
    redirect_to edit_todo_list_path(@todo_list), notice: 'Todo item updated successfully.'
  end

  def destroy
    @todo_item = @todo_list.todo_items.find(params.require(:id))
    @todo_item.destroy
    redirect_to edit_todo_list_path(@todo_list), notice: 'Todo item deleted successfully.'
  end

  private

  def set_todo_list
    @todo_list = TodoList.find(params.require(:todo_list_id))
  end

  def todo_item_params
    params.require(:todo_item).permit(:name, :completed)
  end
end

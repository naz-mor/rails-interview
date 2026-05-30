class TodoItemsController < ApplicationController
  before_action :set_todo_list

  def new
    @todo_item = @todo_list.todo_items.build

    respond_to :html
  end

  def create
    @todo_item = @todo_list.todo_items.build(todo_item_params)

    if @todo_item.save
      redirect_to edit_todo_list_path(@todo_list)
    else
      respond_to :html
    end
  end

  def destroy
    @todo_item = @todo_list.todo_items.find(params[:id])
    @todo_item.destroy
    redirect_to edit_todo_list_path(@todo_list)
  end

  private

  def set_todo_list
    @todo_list = TodoList.find(params[:todo_list_id])
  end

  def todo_item_params
    params.require(:todo_item).permit(:name)
  end
end

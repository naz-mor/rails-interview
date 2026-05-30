module Api
  class TodoItemsController < Api::ApplicationController
    before_action :set_todo_list

    # POST /api/todolists/:todo_list_id/items
    def create
      @todo_item = @todo_list.todo_items.build(todo_item_params)

      if @todo_item.save
        render status: :created
      else
        render json: { errors: @todo_item.errors }, status: :unprocessable_entity
      end
    end

    # DELETE /api/todolists/:todo_list_id/items/:id
    def destroy
      @todo_item = @todo_list.todo_items.find(params.require(:id))
      @todo_item.destroy
    end

    private

    def set_todo_list
      @todo_list = TodoList.find(params.require(:todo_list_id))
    end

    def todo_item_params
      params.require(:todo_item).permit(:name)
    end
  end
end

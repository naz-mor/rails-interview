module Api
  class TodoListsController < Api::ApplicationController

    # GET /api/todolists
    def index
      @todo_lists = TodoList.all
    end

    # POST /api/todolists
    def create
      @todo_list = TodoList.new(todo_list_params)

      if @todo_list.save
        render json: @todo_list, status: :created
      else
        render json: { errors: @todo_list.errors }, status: :unprocessable_entity
      end
    end

    private

    def todo_list_params
      params.require(:todo_list).permit(:name)
    end
  end
end

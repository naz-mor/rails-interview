module TodoLists
  class NameController < App::ApplicationController
    before_action :set_todo_list

    def edit
      render partial: "todo_lists/name/form", locals: { todo_list: @todo_list }
    end

    def update
      if @todo_list.update(todo_list_params)
        render partial: "todo_lists/name/show", locals: { todo_list: @todo_list }
      else
        render partial: "todo_lists/name/form", locals: { todo_list: @todo_list }, status: :unprocessable_entity
      end
    end

    private

    def set_todo_list
      @todo_list = TodoList.find(params.require(:todo_list_id))
    end

    def todo_list_params
      params.require(:todo_list).permit(:name)
    end
  end
end

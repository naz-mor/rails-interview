module TodoLists
  class CompleteAllController < App::ApplicationController
    before_action :set_todo_list

    def create
      now = Time.current
      @todo_list.todo_items.where(completed_at: nil).update_all(completed_at: now, updated_at: now)
      @todo_items = paginate(@todo_list.todo_items)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_todo_list_path(@todo_list), notice: 'All todo items completed successfully.' }
      end
    end

    private

    def set_todo_list
      @todo_list = TodoList.find(params.require(:todo_list_id))
    end
  end
end

module Api
  module TodoLists
    class CompleteAllController < Api::ApplicationController
      before_action :set_todo_list

      # POST /api/todolists/:todo_list_id/complete_all
      def create
        now = Time.current
        @todo_list.todo_items.where(completed_at: nil).update_all(completed_at: now, updated_at: now)

        head :created
      end

      private

      def set_todo_list
        @todo_list = TodoList.find(params.require(:todo_list_id))
      end
    end
  end
end

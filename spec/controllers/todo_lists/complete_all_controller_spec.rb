require 'rails_helper'

describe TodoLists::CompleteAllController do
  let(:todo_list) { TodoList.create!(name: 'My List') }

  describe 'POST create' do
    let!(:todo_item) { todo_list.todo_items.create!(name: 'Buy milk') }
    let!(:completed_item) { todo_list.todo_items.create!(name: 'Done', completed: true) }
    let!(:other_todo_list) { TodoList.create!(name: 'Other List') }
    let!(:other_todo_item) { other_todo_list.todo_items.create!(name: 'Leave alone') }

    it 'completes all incomplete todo items in the requested list' do
      post :create, params: { todo_list_id: todo_list.id }

      expect(todo_item.reload.completed?).to be(true)
      expect(completed_item.reload.completed?).to be(true)
      expect(other_todo_item.reload.completed?).to be(false)
    end

    it 'redirects to the edit todo list page' do
      post :create, params: { todo_list_id: todo_list.id }

      expect(response).to redirect_to(edit_todo_list_path(todo_list))
      expect(flash[:notice]).to eq('All todo items completed successfully.')
    end
  end
end

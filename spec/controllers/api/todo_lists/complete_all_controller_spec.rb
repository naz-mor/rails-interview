require 'rails_helper'

describe Api::TodoLists::CompleteAllController do
  let(:todo_list) { TodoList.create!(name: 'My List') }

  describe 'POST create' do
    let!(:todo_item) { todo_list.todo_items.create!(name: 'Buy milk') }
    let!(:completed_item) { todo_list.todo_items.create!(name: 'Done', completed: true) }
    let!(:other_todo_list) { TodoList.create!(name: 'Other List') }
    let!(:other_todo_item) { other_todo_list.todo_items.create!(name: 'Leave alone') }

    it 'completes all incomplete todo items in the requested list' do
      post :create, params: { todo_list_id: todo_list.id }, format: :json

      expect(todo_item.reload.completed?).to be(true)
      expect(completed_item.reload.completed?).to be(true)
      expect(other_todo_item.reload.completed?).to be(false)
    end

    it 'returns created' do
      post :create, params: { todo_list_id: todo_list.id }, format: :json

      expect(response.status).to eq(201)
      expect(response.body).to be_blank
    end
  end
end

require 'rails_helper'

describe TodoItemsController do
  let(:todo_list) { TodoList.create!(name: 'My List') }

  describe 'GET new' do
    it 'returns a success code' do
      get :new, params: { todo_list_id: todo_list.id }
      expect(response.status).to eq(200)
    end

    it 'assigns a new todo item scoped to the todo list' do
      get :new, params: { todo_list_id: todo_list.id }
      expect(assigns(:todo_item)).to be_a_new(TodoItem)
      expect(assigns(:todo_item).todo_list).to eq(todo_list)
    end
  end

  describe 'POST create' do
    context 'with valid params' do
      it 'creates a new todo item' do
        expect {
          post :create, params: { todo_list_id: todo_list.id, todo_item: { name: 'Buy milk' } }
        }.to change(TodoItem, :count).by(1)
      end

      it 'associates the item with the todo list' do
        post :create, params: { todo_list_id: todo_list.id, todo_item: { name: 'Buy milk' } }
        expect(todo_list.todo_items.last.name).to eq('Buy milk')
      end

      it 'redirects to the edit todo list page' do
        post :create, params: { todo_list_id: todo_list.id, todo_item: { name: 'Buy milk' } }
        expect(response).to redirect_to(edit_todo_list_path(todo_list))
      end
    end

    context 'with invalid params' do
      it 'does not create a todo item' do
        expect {
          post :create, params: { todo_list_id: todo_list.id, todo_item: { name: '' } }
        }.not_to change(TodoItem, :count)
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:todo_item) { todo_list.todo_items.create!(name: 'Buy milk') }

    it 'destroys the todo item' do
      expect {
        delete :destroy, params: { todo_list_id: todo_list.id, id: todo_item.id }
      }.to change(TodoItem, :count).by(-1)
    end

    it 'redirects to the edit todo list page' do
      delete :destroy, params: { todo_list_id: todo_list.id, id: todo_item.id }
      expect(response).to redirect_to(edit_todo_list_path(todo_list))
    end
  end
end

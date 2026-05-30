require 'rails_helper'

describe Api::TodoItemsController do
  render_views

  let(:todo_list) { TodoList.create!(name: 'My List') }

  describe 'POST create' do
    context 'with valid params' do
      it 'creates a new todo item' do
        expect {
          post :create, params: { todo_list_id: todo_list.id, todo_item: { name: 'Buy milk' } }, format: :json
        }.to change(TodoItem, :count).by(1)
      end

      it 'returns a created status code' do
        post :create, params: { todo_list_id: todo_list.id, todo_item: { name: 'Buy milk' } }, format: :json

        expect(response.status).to eq(201)
      end

      it 'returns the created todo item' do
        post :create, params: { todo_list_id: todo_list.id, todo_item: { name: 'Buy milk' } }, format: :json

        todo_item = JSON.parse(response.body)

        aggregate_failures 'includes the id, name, and completed flag' do
          expect(todo_item['id']).not_to be_nil
          expect(todo_item['name']).to eq('Buy milk')
          expect(todo_item['completed']).to be(false)
        end
      end
    end

    context 'with invalid params' do
      it 'does not create a todo item' do
        expect {
          post :create, params: { todo_list_id: todo_list.id, todo_item: { name: '' } }, format: :json
        }.not_to change(TodoItem, :count)
      end

      it 'returns an unprocessable entity status code' do
        post :create, params: { todo_list_id: todo_list.id, todo_item: { name: '' } }, format: :json

        expect(response.status).to eq(422)
      end

      it 'returns errors in the response' do
        post :create, params: { todo_list_id: todo_list.id, todo_item: { name: '' } }, format: :json

        body = JSON.parse(response.body)
        expect(body['errors']['name']).to include("can't be blank")
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:todo_item) { todo_list.todo_items.create!(name: 'Buy milk') }
    let!(:other_todo_list) { TodoList.create!(name: 'Other List') }
    let!(:other_todo_item) { other_todo_list.todo_items.create!(name: 'Leave alone') }

    it 'destroys the todo item' do
      expect {
        delete :destroy, params: { todo_list_id: todo_list.id, id: todo_item.id }, format: :json
      }.to change(TodoItem, :count).by(-1)

      expect(TodoItem.exists?(todo_item.id)).to be(false)
      expect(TodoItem.exists?(other_todo_item.id)).to be(true)
    end

    it 'returns no content' do
      delete :destroy, params: { todo_list_id: todo_list.id, id: todo_item.id }, format: :json

      expect(response.status).to eq(204)
      expect(response.body).to be_blank
    end
  end
end

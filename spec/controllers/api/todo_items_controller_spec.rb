require 'rails_helper'

describe Api::TodoItemsController do
  render_views

  let(:todo_list) { TodoList.create!(name: 'My List') }

  describe 'GET index' do
    context 'when format is HTML' do
      it 'raises a routing error' do
        expect {
          get :index, params: { todo_list_id: todo_list.id }, format: :html
        }.to raise_error(ActionController::RoutingError, 'Not supported format')
      end
    end

    context 'when format is JSON' do
      it 'returns a success code' do
        get :index, params: { todo_list_id: todo_list.id }, format: :json

        expect(response.status).to eq(200)
      end

      it 'returns paginated todo items with the default page size' do
        11.times { |index| todo_list.todo_items.create!(name: "Item #{index}") }

        get :index, params: { todo_list_id: todo_list.id }, format: :json

        todo_items = JSON.parse(response.body)
        expect(todo_items.map { |item| item['id'] }).to eq(todo_list.todo_items.limit(10).pluck(:id))
      end

      it 'uses the requested page and page size' do
        12.times { |index| todo_list.todo_items.create!(name: "Item #{index}") }

        get :index, params: { todo_list_id: todo_list.id, page: 2, per_page: 5 }, format: :json

        todo_items = JSON.parse(response.body)
        expect(todo_items.map { |item| item['id'] }).to eq(todo_list.todo_items.offset(5).limit(5).pluck(:id))
      end
    end
  end

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

  describe 'PATCH update' do
    let!(:todo_item) { todo_list.todo_items.create!(name: 'Buy milk') }
    let!(:other_todo_list) { TodoList.create!(name: 'Other List') }
    let!(:other_todo_item) { other_todo_list.todo_items.create!(name: 'Leave alone') }

    it 'updates the requested todo item' do
      patch :update, params: { todo_list_id: todo_list.id, id: todo_item.id, todo_item: { name: 'Buy bread', completed: '1' } }, format: :json

      expect(todo_item.reload.name).to eq('Buy bread')
      expect(todo_item.completed?).to be(true)
      expect(other_todo_item.reload.name).to eq('Leave alone')
    end

    it 'returns the updated todo item' do
      patch :update, params: { todo_list_id: todo_list.id, id: todo_item.id, todo_item: { name: 'Buy bread', completed: '1' } }, format: :json

      body = JSON.parse(response.body)
      expect(body['name']).to eq('Buy bread')
      expect(body['completed']).to be(true)
    end

    it 'returns errors for invalid params' do
      patch :update, params: { todo_list_id: todo_list.id, id: todo_item.id, todo_item: { name: '' } }, format: :json

      body = JSON.parse(response.body)
      expect(response.status).to eq(422)
      expect(body['errors']['name']).to include("can't be blank")
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

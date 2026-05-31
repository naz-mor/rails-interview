require 'rails_helper'

describe Api::TodoListsController do
  render_views

  describe 'GET index' do
    let!(:todo_list) { TodoList.create(name: 'Setup RoR project') }

    context 'when format is HTML' do
      it 'raises a routing error' do
        expect {
          get :index
        }.to raise_error(ActionController::RoutingError, 'Not supported format')
      end
    end

    context 'when format is JSON' do
      it 'returns the expected content type' do
        get :index, format: :json

        expect(response.media_type).to eq('application/json')
      end

      it 'returns a success code' do
        get :index, format: :json

        expect(response.status).to eq(200)
      end

      it 'includes todo list records' do
        todo_list.todo_items.create!(name: 'First item', completed: true)

        get :index, format: :json

        todo_lists = JSON.parse(response.body)

        aggregate_failures 'includes the id and name' do
          expect(todo_lists.count).to eq(1)
          expect(todo_lists[0].keys).to match_array(['id', 'name'])
          expect(todo_lists[0]['id']).to eq(todo_list.id)
          expect(todo_lists[0]['name']).to eq(todo_list.name)
        end
      end

      it 'uses the default page size' do
        10.times { |index| TodoList.create!(name: "List #{index}") }

        get :index, format: :json

        todo_lists = JSON.parse(response.body)
        expect(todo_lists.map { |list| list['id'] }).to eq(TodoList.order(:id).limit(10).pluck(:id))
      end

      it 'uses the requested page and page size' do
        12.times { |index| TodoList.create!(name: "List #{index}") }

        get :index, params: { page: 2, per_page: 5 }, format: :json

        todo_lists = JSON.parse(response.body)
        expect(todo_lists.map { |list| list['id'] }).to eq(TodoList.order(:id).offset(5).limit(5).pluck(:id))
      end
    end
  end

  describe 'GET show' do
    let!(:todo_list) { TodoList.create!(name: 'My List') }
    let!(:todo_item) { todo_list.todo_items.create!(name: 'Buy milk', completed: true) }

    context 'when format is HTML' do
      it 'raises a routing error' do
        expect {
          get :show, params: { id: todo_list.id }, format: :html
        }.to raise_error(ActionController::RoutingError, 'Not supported format')
      end
    end

    context 'when format is JSON' do
      it 'returns a success code' do
        get :show, params: { id: todo_list.id }, format: :json

        expect(response.status).to eq(200)
      end

      it 'returns the todo list' do
        get :show, params: { id: todo_list.id }, format: :json

        body = JSON.parse(response.body)

        expect(body).to eq('id' => todo_list.id, 'name' => 'My List')
      end
    end
  end

  describe 'POST create' do
    context 'with valid params' do
      it 'creates a new todo list' do
        expect {
          post :create, params: { todo_list: { name: 'New List' } }, format: :json
        }.to change(TodoList, :count).by(1)
      end

      it 'returns a created status code' do
        post :create, params: { todo_list: { name: 'New List' } }, format: :json

        expect(response.status).to eq(201)
      end

      it 'returns the created todo list' do
        post :create, params: { todo_list: { name: 'New List' } }, format: :json

        todo_list = JSON.parse(response.body)

        aggregate_failures 'includes the id and name' do
          expect(todo_list['name']).to eq('New List')
          expect(todo_list['id']).not_to be_nil
        end
      end

      it 'creates nested todo items with permitted attributes' do
        post :create, params: {
          todo_list: {
            name: 'New List',
            todo_items_attributes: [
              { name: 'First item', completed: '1' }
            ]
          }
        }, format: :json

        todo_list = TodoList.find_by!(name: 'New List')
        todo_item = todo_list.todo_items.first!

        expect(todo_item.name).to eq('First item')
        expect(todo_item.completed?).to be(true)
      end

      it 'returns the created todo list' do
        post :create, params: {
          todo_list: {
            name: 'New List',
            todo_items_attributes: [
              { name: 'First item', completed: '1' }
            ]
          }
        }, format: :json

        body = JSON.parse(response.body)

        expect(body).to include('name' => 'New List')
        expect(body.keys).to match_array(['id', 'name'])
      end
    end

    context 'with invalid params' do
      before { TodoList.create!(name: 'Existing List') }

      it 'does not create a todo list' do
        expect {
          post :create, params: { todo_list: { name: 'Existing List' } }, format: :json
        }.not_to change(TodoList, :count)
      end

      it 'returns an unprocessable entity status code' do
        post :create, params: { todo_list: { name: 'Existing List' } }, format: :json

        expect(response.status).to eq(422)
      end

      it 'returns errors in the response' do
        post :create, params: { todo_list: { name: 'Existing List' } }, format: :json

        body = JSON.parse(response.body)
        expect(body['errors']['name']).to include('has already been taken')
      end
    end
  end

  describe 'PATCH update' do
    let!(:other_todo_list) { TodoList.create!(name: 'Other List') }
    let!(:todo_list) { TodoList.create!(name: 'My List') }

    context 'with valid params' do
      it 'updates the todo list' do
        patch :update, params: { id: todo_list.id, todo_list: { name: 'Updated List' } }, format: :json

        expect(todo_list.reload.name).to eq('Updated List')
        expect(other_todo_list.reload.name).to eq('Other List')
      end

      it 'returns the updated todo list' do
        patch :update, params: { id: todo_list.id, todo_list: { name: 'Updated List' } }, format: :json

        body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(body).to include('id' => todo_list.id, 'name' => 'Updated List')
      end

      it 'updates nested todo items with permitted attributes' do
        todo_item = todo_list.todo_items.create!(name: 'Old name')
        removable_item = todo_list.todo_items.create!(name: 'Remove me')

        patch :update, params: {
          id: todo_list.id,
          todo_list: {
            name: 'Updated List',
            todo_items_attributes: [
              { id: todo_item.id, name: 'New name', completed: '1' },
              { id: removable_item.id, _destroy: '1' }
            ]
          }
        }, format: :json

        expect(todo_item.reload.name).to eq('New name')
        expect(todo_item.completed?).to be(true)
        expect(todo_list.todo_items.exists?(removable_item.id)).to be(false)
      end

      it 'returns the updated todo list' do
        todo_item = todo_list.todo_items.create!(name: 'Old name')
        removable_item = todo_list.todo_items.create!(name: 'Remove me')

        patch :update, params: {
          id: todo_list.id,
          todo_list: {
            name: 'Updated List',
            todo_items_attributes: [
              { id: todo_item.id, name: 'New name', completed: '1' },
              { id: removable_item.id, _destroy: '1' }
            ]
          }
        }, format: :json

        body = JSON.parse(response.body)

        expect(body).to eq('id' => todo_list.id, 'name' => 'Updated List')
      end
    end

    context 'with invalid params' do
      it 'does not update the todo list' do
        patch :update, params: { id: todo_list.id, todo_list: { name: 'Other List' } }, format: :json

        expect(todo_list.reload.name).to eq('My List')
      end

      it 'returns an unprocessable entity status code' do
        patch :update, params: { id: todo_list.id, todo_list: { name: 'Other List' } }, format: :json

        expect(response.status).to eq(422)
      end

      it 'returns errors in the response' do
        patch :update, params: { id: todo_list.id, todo_list: { name: 'Other List' } }, format: :json

        body = JSON.parse(response.body)
        expect(body['errors']['name']).to include('has already been taken')
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:other_todo_list) { TodoList.create!(name: 'Other List') }
    let!(:todo_list) { TodoList.create!(name: 'My List') }

    it 'destroys the todo list' do
      expect {
        delete :destroy, params: { id: todo_list.id }, format: :json
      }.to change(TodoList, :count).by(-1)

      expect(TodoList.exists?(todo_list.id)).to be(false)
      expect(TodoList.exists?(other_todo_list.id)).to be(true)
    end

    it 'returns no content' do
      delete :destroy, params: { id: todo_list.id }, format: :json

      expect(response.status).to eq(204)
      expect(response.body).to be_blank
    end
  end
end

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
      it 'returns a success code' do
        get :index, format: :json

        expect(response.status).to eq(200)
      end

      it 'includes todo list records' do
        get :index, format: :json

        todo_lists = JSON.parse(response.body)

        aggregate_failures 'includes the id and name' do
          expect(todo_lists.count).to eq(1)
          expect(todo_lists[0].keys).to match_array(['id', 'name'])
          expect(todo_lists[0]['id']).to eq(todo_list.id)
          expect(todo_lists[0]['name']).to eq(todo_list.name)
        end
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
end

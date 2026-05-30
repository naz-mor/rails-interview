require 'rails_helper'

describe TodoListsController do
  describe 'GET index' do
    let!(:todo_list) { TodoList.create!(name: 'My List') }

    it 'returns a success code' do
      get :index
      expect(response.status).to eq(200)
    end

    it 'assigns all todo lists' do
      get :index
      expect(assigns(:todo_lists)).to include(todo_list)
    end
  end

  describe 'GET new' do
    it 'returns a success code' do
      get :new
      expect(response.status).to eq(200)
    end

    it 'assigns a new todo list' do
      get :new
      expect(assigns(:todo_list)).to be_a_new(TodoList)
    end
  end

  describe 'POST create' do
    context 'with valid params' do
      it 'creates a new todo list' do
        expect {
          post :create, params: { todo_list: { name: 'New List' } }
        }.to change(TodoList, :count).by(1)
      end

      it 'redirects to the todo lists index' do
        post :create, params: { todo_list: { name: 'New List' } }
        expect(response).to redirect_to(todo_lists_path)
      end
    end

    context 'with invalid params' do
      before { TodoList.create!(name: 'Existing List') }

      it 'does not create a todo list' do
        expect {
          post :create, params: { todo_list: { name: 'Existing List' } }
        }.not_to change(TodoList, :count)
      end

      it 'renders new with unprocessable entity status' do
        post :create, params: { todo_list: { name: 'Existing List' } }
        expect(response.status).to eq(422)
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET edit' do
    let(:todo_list) { TodoList.create!(name: 'My List') }

    it 'returns a success code' do
      get :edit, params: { id: todo_list.id }
      expect(response.status).to eq(200)
    end

    it 'assigns the requested todo list' do
      get :edit, params: { id: todo_list.id }
      expect(assigns(:todo_list)).to eq(todo_list)
    end
  end

  describe 'PATCH update' do
    let!(:todo_list) { TodoList.create!(name: 'My List') }

    context 'with valid params' do
      it 'updates the todo list' do
        patch :update, params: { id: todo_list.id, todo_list: { name: 'Updated List' } }
        expect(todo_list.reload.name).to eq('Updated List')
      end

      it 'redirects to the todo lists index' do
        patch :update, params: { id: todo_list.id, todo_list: { name: 'Updated List' } }
        expect(response).to redirect_to(todo_lists_path)
      end
    end

    context 'with invalid params' do
      before { TodoList.create!(name: 'Other List') }

      it 'does not update the todo list' do
        patch :update, params: { id: todo_list.id, todo_list: { name: 'Other List' } }
        expect(todo_list.reload.name).to eq('My List')
      end

      it 'renders edit with unprocessable entity status' do
        patch :update, params: { id: todo_list.id, todo_list: { name: 'Other List' } }
        expect(response.status).to eq(422)
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:todo_list) { TodoList.create!(name: 'My List') }

    it 'destroys the todo list' do
      expect {
        delete :destroy, params: { id: todo_list.id }
      }.to change(TodoList, :count).by(-1)
    end

    it 'redirects to the todo lists index' do
      delete :destroy, params: { id: todo_list.id }
      expect(response).to redirect_to(todo_lists_path)
    end
  end
end

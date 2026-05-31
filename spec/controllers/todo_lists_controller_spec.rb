require 'rails_helper'

describe TodoListsController do
  render_views

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

    it 'rejects unsupported formats' do
      expect { get :index, format: :json }.to raise_error(
        ActionController::RoutingError,
        'Not supported format'
      )
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

    it 'rejects unsupported formats' do
      expect { get :new, format: :json }.to raise_error(
        ActionController::RoutingError,
        'Not supported format'
      )
    end
  end

  describe 'POST create' do
    context 'with valid params' do
      it 'creates a new todo list' do
        expect {
          post :create, params: { todo_list: { name: 'New List' } }, format: :turbo_stream
        }.to change(TodoList, :count).by(1)
      end

      it 'creates nested todo items with permitted attributes' do
        post :create, params: {
          todo_list: {
            name: 'New List',
            todo_items_attributes: [
              { name: 'First item', completed: '1' }
            ]
          }
        }, format: :turbo_stream

        todo_list = TodoList.find_by!(name: 'New List')
        todo_item = todo_list.todo_items.first!

        expect(todo_item.name).to eq('First item')
        expect(todo_item.completed?).to be(true)
      end

      it 'appends the todo list and replaces the inline form for turbo stream requests' do
        post :create, params: { todo_list: { name: 'New List' } }, format: :turbo_stream

        expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
        expect(response).to render_template(:create)
        expect(response.body).to include('action="append" target="todo_lists"')
        expect(response.body).to include('action="replace" target="new_todo_list"')
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
    before { TodoList.create!(name: 'Other List') }

    let(:todo_list) { TodoList.create!(name: 'My List') }

    it 'returns a success code' do
      get :edit, params: { id: todo_list.id }
      expect(response.status).to eq(200)
    end

    it 'assigns the requested todo list' do
      get :edit, params: { id: todo_list.id }
      expect(assigns(:todo_list)).to eq(todo_list)
    end

    it 'rejects unsupported formats' do
      expect { get :edit, params: { id: todo_list.id }, format: :json }.to raise_error(
        ActionController::RoutingError,
        'Not supported format'
      )
    end
  end

  describe 'PATCH update' do
    let!(:other_todo_list) { TodoList.create!(name: 'Other List') }
    let!(:todo_list) { TodoList.create!(name: 'My List') }

    context 'with valid params' do
      it 'updates the todo list' do
        patch :update, params: { id: todo_list.id, todo_list: { name: 'Updated List' } }

        expect(todo_list.reload.name).to eq('Updated List')
        expect(other_todo_list.reload.name).to eq('Other List')
      end

      it 'redirects to the todo lists index' do
        patch :update, params: { id: todo_list.id, todo_list: { name: 'Updated List' } }
        expect(response).to redirect_to(todo_lists_path)
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
        }

        expect(todo_item.reload.name).to eq('New name')
        expect(todo_item.completed?).to be(true)
        expect(todo_list.todo_items.exists?(removable_item.id)).to be(false)
      end
    end

    context 'with invalid params' do
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

  describe 'private helpers' do
    describe '#set_todo_list' do
      it 'loads the requested todo list' do
        TodoList.create!(name: 'Other List')
        todo_list = TodoList.create!(name: 'My List')

        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(id: todo_list.id)
        )

        controller.send(:set_todo_list)

        expect(controller.instance_variable_get(:@todo_list)).to eq(todo_list)
      end

      it 'requires an id param' do
        allow(controller).to receive(:params).and_return(ActionController::Parameters.new)

        expect { controller.send(:set_todo_list) }.to raise_error(
          ActionController::ParameterMissing,
          'param is missing or the value is empty: id'
        )
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:other_todo_list) { TodoList.create!(name: 'Other List') }
    let!(:todo_list) { TodoList.create!(name: 'My List') }

    it 'destroys the todo list' do
      expect {
        delete :destroy, params: { id: todo_list.id }
      }.to change(TodoList, :count).by(-1)

      expect(TodoList.exists?(todo_list.id)).to be(false)
      expect(TodoList.exists?(other_todo_list.id)).to be(true)
    end

    it 'redirects to the todo lists index' do
      delete :destroy, params: { id: todo_list.id }
      expect(response).to redirect_to(todo_lists_path)
    end
  end
end

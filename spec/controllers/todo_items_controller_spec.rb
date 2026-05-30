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

    it 'rejects unsupported formats' do
      expect { get :new, params: { todo_list_id: todo_list.id }, format: :json }.to raise_error(
        ActionController::RoutingError,
        'Not supported format'
      )
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
        expect(flash[:notice]).to eq('Todo item created successfully.')
      end
    end

    context 'with invalid params' do
      it 'does not create a todo item' do
        expect {
          post :create, params: { todo_list_id: todo_list.id, todo_item: { name: '' } }
        }.not_to change(TodoItem, :count)
      end

      it 'renders new with unprocessable entity status' do
        post :create, params: { todo_list_id: todo_list.id, todo_item: { name: '' } }

        expect(response.status).to eq(422)
        expect(response).to render_template(:new)
        expect(assigns(:todo_item).errors[:name]).to include("can't be blank")
      end
    end
  end

  describe 'private helpers' do
    describe '#set_todo_list' do
      it 'loads the requested todo list' do
        TodoList.create!(name: 'Other List')

        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(todo_list_id: todo_list.id)
        )

        controller.send(:set_todo_list)

        expect(controller.instance_variable_get(:@todo_list)).to eq(todo_list)
      end

      it 'requires a todo_list_id param' do
        allow(controller).to receive(:params).and_return(ActionController::Parameters.new)

        expect { controller.send(:set_todo_list) }.to raise_error(
          ActionController::ParameterMissing,
          'param is missing or the value is empty: todo_list_id'
        )
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:other_todo_list) { TodoList.create!(name: 'Other List') }
    let!(:todo_item) { todo_list.todo_items.create!(name: 'Buy milk') }
    let!(:other_todo_item) { other_todo_list.todo_items.create!(name: 'Leave alone') }

    it 'destroys the todo item' do
      expect {
        delete :destroy, params: { todo_list_id: todo_list.id, id: todo_item.id }
      }.to change(TodoItem, :count).by(-1)

      expect(TodoItem.exists?(todo_item.id)).to be(false)
      expect(TodoItem.exists?(other_todo_item.id)).to be(true)
    end

    it 'redirects to the edit todo list page' do
      delete :destroy, params: { todo_list_id: todo_list.id, id: todo_item.id }
      expect(response).to redirect_to(edit_todo_list_path(todo_list))
      expect(flash[:notice]).to eq('Todo item deleted successfully.')
    end
  end
end

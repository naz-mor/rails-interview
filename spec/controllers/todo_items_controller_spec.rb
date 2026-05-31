require 'rails_helper'

describe TodoItemsController do
  render_views

  let(:todo_list) { TodoList.create!(name: 'My List') }

  describe 'GET index' do
    it 'returns a success code' do
      get :index, params: { todo_list_id: todo_list.id }

      expect(response.status).to eq(200)
    end

    it 'renders todo items with the default page size' do
      11.times { |index| todo_list.todo_items.create!(name: "Item #{index}") }

      get :index, params: { todo_list_id: todo_list.id }

      expect(assigns(:todo_items).to_a).to eq(todo_list.todo_items.limit(10).to_a)
      expect(response.body).not_to include(todo_list.todo_items.offset(10).first.name)
    end

    it 'uses the requested page and page size' do
      12.times { |index| todo_list.todo_items.create!(name: "Item #{index}") }

      get :index, params: { todo_list_id: todo_list.id, page: 2, per_page: 5 }

      expect(assigns(:todo_items).to_a).to eq(todo_list.todo_items.offset(5).limit(5).to_a)
    end

    it 'renders the requested todo items page inside its turbo frame' do
      12.times { |index| todo_list.todo_items.create!(name: "Item #{index}") }

      get :index, params: { todo_list_id: todo_list.id, page: 2, per_page: 5 }

      expect(response.body).to include('id="todo_items_page_2"')
      expect(response.body).to include(todo_list.todo_items.offset(5).first.name)
      expect(response.body).to include('id="todo_items_page_3"')
    end

    it 'rejects unsupported formats' do
      expect { get :index, params: { todo_list_id: todo_list.id }, format: :json }.to raise_error(
        ActionController::RoutingError,
        'Not supported format'
      )
    end
  end

  describe 'POST create' do
    context 'with valid params' do
      it 'creates a new todo item' do
        expect {
          post :create, params: { todo_list_id: todo_list.id, todo_item: { name: 'Buy milk' } }, format: :turbo_stream
        }.to change(TodoItem, :count).by(1)
      end

      it 'associates the item with the todo list' do
        post :create, params: { todo_list_id: todo_list.id, todo_item: { name: 'Buy milk' } }, format: :turbo_stream
        expect(todo_list.todo_items.last.name).to eq('Buy milk')
      end

      it 'prepends the todo item and replaces the inline form and complete-all button for turbo stream requests' do
        post :create, params: { todo_list_id: todo_list.id, todo_item: { name: 'Buy milk' } }, format: :turbo_stream

        expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
        expect(response).to render_template(:create)
        expect(response.body).to include('action="prepend" target="todo_items"')
        expect(response.body).to include('action="replace" target="new_todo_item"')
        expect(response.body).to include("action=\"replace\" target=\"complete_all_todo_list_#{todo_list.id}\"")
      end

      it 'redirects to the edit todo list page for html requests' do
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

  describe 'PATCH update' do
    let!(:existing_todo_item) { todo_list.todo_items.create!(name: 'Already here') }
    let!(:todo_item) { todo_list.todo_items.create!(name: 'Buy milk') }
    let!(:other_todo_list) { TodoList.create!(name: 'Other List') }
    let!(:other_todo_item) { other_todo_list.todo_items.create!(name: 'Leave alone') }

    it 'updates the requested todo item' do
      patch :update, params: { todo_list_id: todo_list.id, id: todo_item.id, todo_item: { name: 'Buy bread', completed: '1' } }

      expect(todo_item.reload.name).to eq('Buy bread')
      expect(todo_item.completed?).to be(true)
      expect(existing_todo_item.reload.name).to eq('Already here')
      expect(existing_todo_item.completed?).to be(false)
      expect(other_todo_item.reload.name).to eq('Leave alone')
    end

    it 'redirects to the edit todo list page' do
      patch :update, params: { todo_list_id: todo_list.id, id: todo_item.id, todo_item: { completed: '1' } }

      expect(response).to redirect_to(edit_todo_list_path(todo_list))
      expect(flash[:notice]).to eq('Todo item updated successfully.')
    end

    it 'replaces the todo items list and complete-all button for turbo stream requests' do
      patch :update, params: { todo_list_id: todo_list.id, id: todo_item.id, todo_item: { completed: '1' } }, format: :turbo_stream

      expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
      expect(response).to render_template(:update)
      expect(response.body).to include('action="replace" target="todo_items"')
      expect(response.body).to include("action=\"replace\" target=\"complete_all_todo_list_#{todo_list.id}\"")
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

    it 'removes the todo item for turbo stream requests' do
      delete :destroy, params: { todo_list_id: todo_list.id, id: todo_item.id }, format: :turbo_stream

      expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
      expect(response).to render_template(:destroy)
      expect(response.body).to include('action="remove" target="todo_item_')
      expect(response.body).to include("target=\"todo_item_#{todo_item.id}\"")
    end
  end
end

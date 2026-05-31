require 'rails_helper'

describe TodoListsController do
  render_views

  describe 'GET index' do
    let!(:todo_list) { TodoList.create!(name: 'My List') }

    it 'returns a success code' do
      get :index
      expect(response.status).to eq(200)
    end

    it 'assigns todo lists with the default page size' do
      10.times { |index| TodoList.create!(name: "List #{index}") }

      get :index

      expect(assigns(:todo_lists).to_a).to eq(TodoList.order(:id).limit(10).to_a)
    end

    it 'uses the requested page and page size' do
      12.times { |index| TodoList.create!(name: "List #{index}") }

      get :index, params: { page: 2, per_page: 5 }

      expect(assigns(:todo_lists).to_a).to eq(TodoList.order(:id).offset(5).limit(5).to_a)
    end

    it 'renders a lazy next-page frame when more todo lists exist' do
      10.times { |index| TodoList.create!(name: "List #{index}") }

      get :index

      expect(response.body).to include('id="todo_lists_page_2"')
      expect(response.body).to include('loading="lazy"')
      expect(response.body).to include('Loading…')
    end

    it 'renders the requested todo lists page inside its turbo frame' do
      12.times { |index| TodoList.create!(name: "List #{index}") }
      request.headers['Turbo-Frame'] = 'todo_lists_page_2'

      get :index, params: { page: 2, per_page: 5 }

      expect(response.body).to include('id="todo_lists_page_2"')
      expect(response.body).to include(TodoList.order(:id).offset(5).first.name)
      expect(response.body).to include('id="todo_lists_page_3"')
    end

    it 'rejects unsupported formats' do
      expect { get :index, format: :json }.to raise_error(
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

      it 'redirects to the todo lists index for html requests' do
        post :create, params: { todo_list: { name: 'New List' } }

        expect(response).to redirect_to(todo_lists_path)
        expect(flash[:notice]).to eq('Todo list created successfully.')
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

    it 'renders todo items with uncompleted items first, newest to oldest' do
      old_completed = todo_list.todo_items.create!(name: 'Old completed', completed_at: 3.days.ago, created_at: 3.days.ago, updated_at: 3.days.ago)
      new_completed = todo_list.todo_items.create!(name: 'New completed', completed_at: 2.days.ago, created_at: 2.days.ago, updated_at: 2.days.ago)
      old_uncompleted = todo_list.todo_items.create!(name: 'Old uncompleted', created_at: 4.days.ago, updated_at: 4.days.ago)
      new_uncompleted = todo_list.todo_items.create!(name: 'New uncompleted', created_at: 1.day.ago, updated_at: 1.day.ago)

      get :edit, params: { id: todo_list.id }

      item_names = [new_uncompleted, old_uncompleted, new_completed, old_completed].map(&:name)
      item_positions = item_names.map { |name| response.body.index(name) }

      expect(item_positions).to eq(item_positions.sort)
    end

    it 'assigns todo items with the default page size' do
      11.times { |index| todo_list.todo_items.create!(name: "Item #{index}") }

      get :edit, params: { id: todo_list.id }

      expect(assigns(:todo_items).to_a).to eq(todo_list.todo_items.limit(10).to_a)
    end

    it 'uses the requested todo items page and page size' do
      12.times { |index| todo_list.todo_items.create!(name: "Item #{index}") }

      get :edit, params: { id: todo_list.id, page: 2, per_page: 5 }

      expect(assigns(:todo_items).to_a).to eq(todo_list.todo_items.offset(5).limit(5).to_a)
    end

    it 'renders only the requested todo items page' do
      11.times { |index| todo_list.todo_items.create!(name: "Item #{index}") }

      get :edit, params: { id: todo_list.id }

      expect(response.body).not_to include(todo_list.todo_items.offset(10).first.name)
    end

    it 'renders a lazy next-page frame when more todo items exist' do
      11.times { |index| todo_list.todo_items.create!(name: "Item #{index}") }

      get :edit, params: { id: todo_list.id }

      expect(response.body).to include('id="todo_items_page_2"')
      expect(response.body).to include('loading="lazy"')
      expect(response.body).to include('Loading…')
    end

    it 'renders the complete-all icon as unchecked when there are incomplete items' do
      todo_list.todo_items.create!(name: 'Buy milk')

      get :edit, params: { id: todo_list.id }

      expect(response.body).to include('aria-label="Complete all tasks"')
    end

    it 'renders the complete-all icon as checked and disabled when all items are completed' do
      todo_list.todo_items.create!(name: 'Buy milk', completed: true)

      get :edit, params: { id: todo_list.id }

      expect(response.body).to include('alt="All tasks completed"')
      expect(response.body).to include('disabled="disabled"')
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

      it 'does not update nested todo items' do
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

        expect(todo_item.reload.name).to eq('Old name')
        expect(todo_item.completed?).to be(false)
        expect(todo_list.todo_items.exists?(removable_item.id)).to be(true)
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

    it 'removes the todo list for turbo stream requests' do
      delete :destroy, params: { id: todo_list.id }, format: :turbo_stream

      expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
      expect(response).to render_template(:destroy)
      expect(response.body).to include('action="remove" target="todo_list_')
      expect(response.body).to include("target=\"todo_list_#{todo_list.id}\"")
    end
  end
end

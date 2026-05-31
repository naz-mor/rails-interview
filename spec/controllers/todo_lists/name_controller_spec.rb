require 'rails_helper'

describe TodoLists::NameController do
  render_views

  let!(:other_todo_list) { TodoList.create!(name: 'Other List') }
  let!(:todo_list) { TodoList.create!(name: 'My List') }

  describe 'GET edit' do
    it 'renders the name edit form' do
      get :edit, params: { todo_list_id: todo_list.id }

      expect(response.status).to eq(200)
      expect(response.body).to include("id=\"name_todo_list_#{todo_list.id}\"")
      expect(response.body).to include("action=\"#{todo_list_name_path(todo_list)}\"")
      expect(response.body).to include('Save')
      expect(response.body).to include('Cancel')
    end
  end

  describe 'PATCH update' do
    it 'updates the requested todo list name' do
      patch :update, params: { todo_list_id: todo_list.id, todo_list: { name: 'Updated List' } }

      expect(todo_list.reload.name).to eq('Updated List')
      expect(other_todo_list.reload.name).to eq('Other List')
    end

    it 'renders the updated name frame' do
      patch :update, params: { todo_list_id: todo_list.id, todo_list: { name: 'Updated List' } }

      expect(response.status).to eq(200)
      expect(response.body).to include("id=\"name_todo_list_#{todo_list.id}\"")
      expect(response.body).to include('Updated List')
      expect(response.body).not_to include('todo-list-name-form')
    end

    it 'renders the name form with errors when invalid' do
      patch :update, params: { todo_list_id: todo_list.id, todo_list: { name: 'Other List' } }

      expect(response.status).to eq(422)
      expect(response.body).to include('todo-list-name-form')
      expect(response.body).to include('Name has already been taken')
    end
  end
end

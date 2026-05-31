require 'rails_helper'

describe Api::TodoLists::CompleteAllController do
  let(:todo_list) { TodoList.create!(name: 'My List') }

  describe 'POST create' do
    let!(:todo_item) { todo_list.todo_items.create!(name: 'Buy milk') }
    let!(:completed_item) { todo_list.todo_items.create!(name: 'Done', completed_at: 2.days.ago, updated_at: 2.days.ago) }
    let!(:other_todo_list) { TodoList.create!(name: 'Other List') }
    let!(:other_todo_item) { other_todo_list.todo_items.create!(name: 'Leave alone') }

    it 'completes all incomplete todo items in the requested list' do
      completed_at = completed_item.completed_at
      post :create, params: { todo_list_id: todo_list.id }, format: :json

      expect(todo_item.reload.completed?).to be(true)
      expect(todo_item.updated_at).to eq(todo_item.completed_at)
      expect(completed_item.reload.completed?).to be(true)
      expect(completed_item.completed_at).to be_within(0.001.seconds).of(completed_at)
      expect(other_todo_item.reload.completed?).to be(false)
    end

    it 'uses the same timestamp for completed_at and updated_at' do
      now = Time.zone.local(2026, 5, 31, 12, 0, 0)
      allow(Time).to receive(:current).and_return(now)

      post :create, params: { todo_list_id: todo_list.id }, format: :json

      expect(todo_item.reload.completed_at).to eq(now)
      expect(todo_item.updated_at).to eq(now)
    end

    it 'returns created' do
      post :create, params: { todo_list_id: todo_list.id }, format: :json

      expect(response.status).to eq(201)
      expect(response.body).to be_blank
    end
  end
end

require 'rails_helper'

describe TodoList do
  describe 'validations' do
    it 'is valid with a unique name' do
      expect(TodoList.new(name: 'My List')).to be_valid
    end

    it 'is invalid without a name' do
      todo_list = TodoList.new

      expect(todo_list).not_to be_valid
      expect(todo_list.errors[:name]).to include("can't be blank")
    end

    it 'is invalid with a blank name' do
      todo_list = TodoList.new(name: '   ')

      expect(todo_list).not_to be_valid
      expect(todo_list.errors[:name]).to include("can't be blank")
    end

    it 'is invalid when name is duplicated' do
      TodoList.create!(name: 'My List')
      duplicate = TodoList.new(name: 'My List')

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include('has already been taken')
    end

    it 'requires name at the database level' do
      expect {
        TodoList.connection.execute("INSERT INTO todo_lists (name) VALUES (NULL)")
      }.to raise_error(ActiveRecord::StatementInvalid)
    end

    it 'requires a non-blank name at the database level' do
      expect {
        TodoList.connection.execute("INSERT INTO todo_lists (name) VALUES ('   ')")
      }.to raise_error(ActiveRecord::StatementInvalid)
    end
  end

  describe 'associations' do
    let(:todo_list) { TodoList.create!(name: 'My List') }

    it 'has many todo_items' do
      todo_list.todo_items.create!(name: 'Item 1')
      todo_list.todo_items.create!(name: 'Item 2')

      expect(todo_list.todo_items.count).to eq(2)
    end

    it 'orders todo_items with uncompleted items first, then newest to oldest' do
      old_completed = todo_list.todo_items.create!(name: 'Old completed', completed_at: 3.days.ago, created_at: 3.days.ago, updated_at: 3.days.ago)
      new_completed = todo_list.todo_items.create!(name: 'New completed', completed_at: 2.days.ago, created_at: 2.days.ago, updated_at: 2.days.ago)
      old_uncompleted = todo_list.todo_items.create!(name: 'Old uncompleted', created_at: 4.days.ago, updated_at: 4.days.ago)
      new_uncompleted = todo_list.todo_items.create!(name: 'New uncompleted', created_at: 1.day.ago, updated_at: 1.day.ago)

      expect(todo_list.todo_items).to eq([new_uncompleted, old_uncompleted, new_completed, old_completed])
    end

    it 'destroys associated todo_items on destroy' do
      todo_list.todo_items.create!(name: 'Item 1')

      expect { todo_list.destroy }.to change(TodoItem, :count).by(-1)
    end
  end

  describe 'nested attributes' do
    it 'creates todo_items via nested attributes' do
      todo_list = TodoList.create!(name: 'My List', todo_items_attributes: [{ name: 'Item 1' }])

      expect(todo_list.todo_items.count).to eq(1)
    end

    it 'destroys todo_items via nested attributes with _destroy flag' do
      todo_list = TodoList.create!(name: 'My List')
      item = todo_list.todo_items.create!(name: 'Item 1')

      todo_list.update!(todo_items_attributes: [{ id: item.id, _destroy: '1' }])

      expect(todo_list.todo_items.count).to eq(0)
    end
  end
end

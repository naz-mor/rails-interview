require 'rails_helper'

describe TodoList do
  describe 'validations' do
    it 'is valid with a unique name' do
      expect(TodoList.new(name: 'My List')).to be_valid
    end

    it 'is invalid when name is duplicated' do
      TodoList.create!(name: 'My List')
      duplicate = TodoList.new(name: 'My List')

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include('has already been taken')
    end
  end

  describe 'associations' do
    let(:todo_list) { TodoList.create!(name: 'My List') }

    it 'has many todo_items' do
      todo_list.todo_items.create!(name: 'Item 1')
      todo_list.todo_items.create!(name: 'Item 2')

      expect(todo_list.todo_items.count).to eq(2)
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

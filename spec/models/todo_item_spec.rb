require 'rails_helper'

describe TodoItem do
  let(:todo_list) { TodoList.create!(name: 'My List') }

  describe 'validations' do
    it 'is valid with a name and todo_list' do
      expect(TodoItem.new(name: 'Buy milk', todo_list: todo_list)).to be_valid
    end

    it 'is invalid without a name' do
      expect(TodoItem.new(todo_list: todo_list)).not_to be_valid
    end

    it 'is invalid without a todo_list' do
      expect(TodoItem.new(name: 'Buy milk')).not_to be_valid
    end
  end

  describe '.ordered_by_completed' do
    it 'orders uncompleted items before completed items by default' do
      completed = todo_list.todo_items.create!(name: 'Completed', completed_at: 3.days.ago, created_at: 3.days.ago, updated_at: 3.days.ago)
      uncompleted = todo_list.todo_items.create!(name: 'Uncompleted', created_at: 4.days.ago, updated_at: 4.days.ago)

      expect(TodoItem.ordered_by_completed).to eq([uncompleted, completed])
    end

    it 'accepts a direction for the timestamp boolean order' do
      completed = todo_list.todo_items.create!(name: 'Completed', completed_at: 3.days.ago, created_at: 3.days.ago, updated_at: 3.days.ago)
      uncompleted = todo_list.todo_items.create!(name: 'Uncompleted', created_at: 4.days.ago, updated_at: 4.days.ago)

      expect(TodoItem.ordered_by_completed(:desc)).to eq([completed, uncompleted])
    end

    it 'raises for unsupported directions' do
      expect { TodoItem.ordered_by_completed(:sideways) }.to raise_error(ArgumentError, 'direction must be :asc or :desc')
    end
  end

  describe '#completed?' do
    it 'returns false when completed_at is nil' do
      item = TodoItem.new(name: 'Buy milk', todo_list: todo_list)
      expect(item.completed?).to be false
    end

    it 'returns true when completed_at is set' do
      item = TodoItem.new(name: 'Buy milk', todo_list: todo_list, completed_at: Time.current)
      expect(item.completed?).to be true
    end
  end

  describe '#completed=' do
    it 'sets completed_at to current time when assigned true' do
      item = TodoItem.new(name: 'Buy milk', todo_list: todo_list)
      item.completed = true

      expect(item.completed_at).not_to be_nil
    end

    it 'clears completed_at when assigned false' do
      item = TodoItem.new(name: 'Buy milk', todo_list: todo_list, completed_at: Time.current)
      item.completed = false

      expect(item.completed_at).to be_nil
    end

    it 'does not overwrite completed_at when already completed and assigned true again' do
      original_time = 1.hour.ago
      item = TodoItem.new(name: 'Buy milk', todo_list: todo_list, completed_at: original_time)
      item.completed = true

      expect(item.completed_at).to be_within(1.second).of(original_time)
    end
  end
end

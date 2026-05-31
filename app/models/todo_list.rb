class TodoList < ApplicationRecord
  has_many :todo_items, dependent: :destroy

  accepts_nested_attributes_for :todo_items, allow_destroy: true

  validates :name, presence: true, uniqueness: true
end

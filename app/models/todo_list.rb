class TodoList < ApplicationRecord
  validates :name, uniqueness: true
end

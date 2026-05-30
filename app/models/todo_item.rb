class TodoItem < ApplicationRecord
  include TimestampBoolean

  belongs_to :todo_list

  validates :name, presence: true

  timestamp_boolean :completed
end

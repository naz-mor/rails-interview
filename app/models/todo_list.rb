class TodoList < ApplicationRecord
  has_many :todo_items, -> { ordered_by_completed(:asc).order(created_at: :desc) }, dependent: :destroy

  scope :ordered_by_recently_updated, -> { order(updated_at: :desc, id: :desc) }

  accepts_nested_attributes_for :todo_items, allow_destroy: true

  validates :name, presence: true, uniqueness: true
end

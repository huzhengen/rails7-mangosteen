class Item < ApplicationRecord
  enum kind: { expenses: 1, income: 2 }
  validates :amount, presence: true
  validates :tags_id, presence: true
  validates :happen_at, presence: true
end

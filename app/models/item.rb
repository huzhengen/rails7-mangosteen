class Item < ApplicationRecord
  enum kind: { expenses: 1, income: 2 }
  validates :amount, presence: true
  validates :tags_id, presence: true
  validates :happen_at, presence: true

  validate :check_tags_id_belong_to_user

  def check_tags_id_belong_to_user
    all_tag_ids = Tag.where({ user_id: self.user_id }).map(&:id)
    if self.tags_id & all_tag_ids != self.tags_id
      self.errors.add :tags_id, "Tag does not belong to the current user"
    end
  end
end

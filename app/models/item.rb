class Item < ApplicationRecord
  enum kind: { expenses: 1, income: 2 }
  validates :amount, presence: true
  validates :kind, presence: true
  validates :tag_ids, presence: true
  validates :happen_at, presence: true

  belongs_to :user

  validate :check_tags_id_belong_to_user

  def check_tags_id_belong_to_user
    all_tag_ids = Tag.where({ user_id: self.user_id }).map(&:id)
    if self.tag_ids & all_tag_ids != self.tag_ids
      self.errors.add :tag_ids, "Tag does not belong to the current user"
    end
  end
end

class Like < ApplicationRecord
  belongs_to :user
  belongs_to :business_idea
  validates :user_id, uniqueness: { scope: :business_idea_id }
end

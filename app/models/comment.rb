class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :business_idea
  validates :body, presence: true
end

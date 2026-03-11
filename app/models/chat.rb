class Chat < ApplicationRecord
  belongs_to :business_idea
  has_many :messages, dependent: :destroy
end

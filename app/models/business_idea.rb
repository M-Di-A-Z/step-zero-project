class BusinessIdea < ApplicationRecord
  belongs_to :user
  has_one :business_data, class_name: "BusinessData", dependent: :destroy
  has_one :chat, dependent: :destroy
  validates :content, presence: true
end

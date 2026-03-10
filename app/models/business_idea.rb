class BusinessIdea < ApplicationRecord
  belongs_to :user
  has_one :business_data, class_name: "BusinessData"
  validates :content, presence: true
end

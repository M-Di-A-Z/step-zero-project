class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :business_ideas
  has_many :likes, dependent: :destroy
  has_many :liked_business_ideas, through: :likes, source: :business_idea
  has_many :comments, dependent: :destroy
  has_one_attached :avatar
end

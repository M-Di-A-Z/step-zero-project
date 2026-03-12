class BusinessIdea < ApplicationRecord
  # associations
  belongs_to :user
  has_one :business_data, class_name: "BusinessData", dependent: :destroy
  has_one :chat, dependent: :destroy
  validates :content, presence: true
  # validation sur le status avec une valeur par defaut comprise dans la liste des status
  # autre methodes

  enum :status, { 'in progress': 1, pending: 0, complete: 2, aborted: 3, researching: 4 }
  # creer un enum (=> enumerateur), qui est une liste figee predeterminee
  # dans laquelle le user va puiser le statut qu'il faut
  # enum :status, { pending: 0, in_progress: 1, completed: 2 } ou enum :status, [:pending, :in_progress, :completed]
  # Task.pending            # => Returns all tasks with status "pending"
  # ce aque ça permet de faire :
  # BusinessIdea.pending!           # => Sets the task’s status to “pending”
  # BusinessIdea.pending?           # => Returns true if the task’s status is "pending"
  # BusinessIdea.status = "pending" # Sets the status of a specific task
  # https://medium.com/jungletronics/mastering-enums-in-rails-9c532211ffdb
end

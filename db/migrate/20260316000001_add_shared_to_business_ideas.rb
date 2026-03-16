class AddSharedToBusinessIdeas < ActiveRecord::Migration[8.0]
  def change
    add_column :business_ideas, :shared, :boolean, default: false, null: false
  end
end

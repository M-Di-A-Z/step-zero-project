class AddSubscoresToBusinessIdeas < ActiveRecord::Migration[8.1]
  def change
    add_column :business_ideas, :score_market, :integer
    add_column :business_ideas, :score_competition, :integer
    add_column :business_ideas, :score_feasibility, :integer
    add_column :business_ideas, :score_execution, :integer
  end
end

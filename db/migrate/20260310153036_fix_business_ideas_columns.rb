class FixBusinessIdeasColumns < ActiveRecord::Migration[8.1]
  def change
    add_column :business_ideas, :summary, :text
    add_column :business_ideas, :idea_score, :integer
    add_column :business_ideas, :details, :text
    remove_column :business_ideas, :report, :string
  end
end

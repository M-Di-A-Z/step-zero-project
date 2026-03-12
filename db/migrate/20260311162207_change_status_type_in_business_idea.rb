class ChangeStatusTypeInBusinessIdea < ActiveRecord::Migration[8.1]
  def up
    change_column :business_ideas, :status, :integer,
      default: 0,
      using: <<~SQL
        CASE status
          WHEN 'pending' THEN 0
          WHEN 'in_progress' THEN 1
          WHEN 'complete' THEN 2
          WHEN 'aborted' THEN 3
          ELSE 0
        END
      SQL
  end

  def down
    change_column :business_ideas, :status, :string
  end
end

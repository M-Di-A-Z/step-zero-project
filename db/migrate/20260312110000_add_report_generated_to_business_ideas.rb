class AddReportGeneratedToBusinessIdeas < ActiveRecord::Migration[8.1]
  def change
    add_column :business_ideas, :report_generated, :boolean, default: false, null:false
  end
end

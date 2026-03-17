class AddLaunchPlanToBusinessData < ActiveRecord::Migration[8.1]
  def change
    add_column :business_data, :launch_plan, :jsonb
  end
end

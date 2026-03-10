class CreateBusinessData < ActiveRecord::Migration[8.1]
  def change
    create_table :business_data do |t|
      t.references :business_idea, null: false, foreign_key: true
      t.string :market_size
      t.string :competitors
      t.string :business
      t.string :execution

      t.timestamps
    end
  end
end

class DropFavorites < ActiveRecord::Migration[8.1]
  def change
    drop_table :favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :business_idea, null: false, foreign_key: true
      t.timestamps
    end
  end
end

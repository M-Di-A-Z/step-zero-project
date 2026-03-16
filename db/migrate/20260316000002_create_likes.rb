class CreateLikes < ActiveRecord::Migration[8.0]
  def change
    create_table :likes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :business_idea, null: false, foreign_key: true
      t.timestamps
    end
    add_index :likes, [:user_id, :business_idea_id], unique: true
  end
end

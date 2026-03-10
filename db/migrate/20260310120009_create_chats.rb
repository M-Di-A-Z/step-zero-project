class CreateChats < ActiveRecord::Migration[8.1]
  def change
    create_table :chats do |t|
      t.references :business_idea, null: false, foreign_key: true
      t.string :title

      t.timestamps
    end
  end
end

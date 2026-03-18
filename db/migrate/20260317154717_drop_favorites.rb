class DropFavorites < ActiveRecord::Migration[8.1]
  def change
    drop_table :favorites, if_exists: true
  end
end

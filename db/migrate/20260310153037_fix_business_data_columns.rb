class FixBusinessDataColumns < ActiveRecord::Migration[8.1]
  def change
    remove_column :business_data, :market_size, :string
    remove_column :business_data, :competitors, :string
    remove_column :business_data, :business, :string
    remove_column :business_data, :execution, :string
    add_column :business_data, :overview,    :jsonb
    add_column :business_data, :market_size, :jsonb
    add_column :business_data, :competitors, :jsonb
    add_column :business_data, :business,    :jsonb
    add_column :business_data, :execution,   :jsonb
  end
end

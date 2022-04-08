class AddGenerationToItem < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :generation, :integer, default: nil
    add_column :test_items, :generation, :integer, default: nil
  end
end

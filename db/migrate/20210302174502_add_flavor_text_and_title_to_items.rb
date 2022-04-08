class AddFlavorTextAndTitleToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :flavor_text, :string
    add_column :items, :title, :string
    add_column :test_items, :flavor_text, :string
    add_column :test_items, :title, :string
  end
end

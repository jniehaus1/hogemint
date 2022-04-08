class AddProcessingToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :processing, :boolean, default: true
  end
end

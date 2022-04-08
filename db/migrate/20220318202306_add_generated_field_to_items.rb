class AddGeneratedFieldToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :generated_gif_url, :string
  end
end

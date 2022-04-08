class CreateBaseItems < ActiveRecord::Migration[5.2]
  def change
    create_table :base_items do |t|
      t.string :uri
      t.string :owner

      t.timestamps
    end

    add_attachment :base_items, :image
  end
end

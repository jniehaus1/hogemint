class CreateTestItem < ActiveRecord::Migration[5.2]
  def change
    create_table :test_items do |t|
      t.integer :token_id
      t.string  :uri
      t.string  :owner
      t.string  :image_hash
      t.timestamps
    end
  end
end

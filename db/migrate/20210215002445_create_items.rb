class CreateItems < ActiveRecord::Migration[5.2]
  def change
    create_table :items do |t|
      t.integer :token_id

      t.timestamps
    end
  end
end

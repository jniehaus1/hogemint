class CreateTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :tokens do |t|
      t.string :uri
      t.string :owner

      t.timestamps
    end
  end
end

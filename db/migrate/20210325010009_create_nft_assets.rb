class CreateNftAssets < ActiveRecord::Migration[5.2]
  def change
    create_table :nft_assets do |t|
      t.string :nft_model_type
      t.integer :nft_model_type

      t.timestamps
    end
  end
end

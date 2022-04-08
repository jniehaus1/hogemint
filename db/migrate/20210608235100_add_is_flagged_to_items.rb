class AddIsFlaggedToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :is_flagged, :boolean
  end
end

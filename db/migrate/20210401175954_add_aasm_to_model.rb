class AddAasmToModel < ActiveRecord::Migration[5.2]
  def change
    add_column :sales, :aasm_state, :string
  end
end

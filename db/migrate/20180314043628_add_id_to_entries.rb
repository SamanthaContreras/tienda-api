class AddIdToEntries < ActiveRecord::Migration[5.1]
  def change
    add_column :entries, :id, :primary_key
  end
end

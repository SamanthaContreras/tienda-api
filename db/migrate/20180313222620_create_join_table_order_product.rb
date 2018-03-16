class CreateJoinTableOrderProduct < ActiveRecord::Migration[5.1]
  def up
    create_join_table :products, :orders, table_name: :entries do |t|
      t.index :product_id
      t.index :order_id
      t.integer :qty
      t.float :import
    end
  end

  def down
    drop_table :entries
  end
end

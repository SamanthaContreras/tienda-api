class CreateOrders < ActiveRecord::Migration[5.1]
  def up
    create_table :orders do |t|
      t.references :user, index: true, foreign_key: true
      t.float :total
      t.float :iva
      t.float :sub_total
    end
  end

  def down
    drop_table :orders
  end
end

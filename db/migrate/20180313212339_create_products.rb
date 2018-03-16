class CreateProducts < ActiveRecord::Migration[5.1]
  def up
    create_table :products do |t|
      t.string :name
      t.float :price
    end
  end

  def down
    drop_table :products
  end
end

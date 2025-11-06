class CreatePlans < ActiveRecord::Migration[7.1]
  def change
    create_table :plans do |t|
      t.string :plan_name
      t.integer :plan_price
      t.timestamps
    end
  end
end

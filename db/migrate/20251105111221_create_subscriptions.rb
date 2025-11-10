# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :stripe_subscription_id
      t.string :status
      t.datetime :started_at
      t.datetime :ended_at
      t.integer :price_cents
      t.timestamps
    end
  end
end

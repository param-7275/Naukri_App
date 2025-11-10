# frozen_string_literal: true

class AddStripeSubscriptionIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :stripe_subscription_id, :string
    add_column :users, :stripe_payment_intent_id, :string
    add_column :users, :stripe_payment_method_id, :string
  end
end

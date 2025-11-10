# frozen_string_literal: true

# class SubscriptionsController < ApplicationController
#   before_action :require_login

#   def new
#   end

#   def create
#     if current_user.stripe_customer_id.blank?
#       customer = Stripe::Customer.create(
#         name: current_user.username,
#         email: current_user.email
#       )
#       current_user.update!(stripe_customer_id: customer.id)
#     end

#     session = Stripe::Checkout::Session.create(
#       customer: current_user.stripe_customer_id,
#       payment_method_types: ['card'],
#       mode: 'subscription',            # or 'payment' if one‑time
#       line_items: [
#         {
#           price_data: {
#             currency: 'inr',
#             unit_amount: 49900,        # ₹499 → amount in paise/lowest unit (₹499 * 100)
#             product_data: {
#               name: 'Premium Plan'
#             },
#             recurring: {
#               interval: 'month'         # for monthly subscription
#             }
#           },
#           quantity: 1
#         }
#       ],
#       success_url: success_subscriptions_url + "?session_id={CHECKOUT_SESSION_ID}",
#       cancel_url: cancel_subscriptions_url
#     )

#     redirect_to session.url, allow_other_host: true
#   rescue Stripe::StripeError => e
#     flash[:alert] = "Payment error: #{e.message}"
#     redirect_to pricing_path
#   end

#   def success
#     session_id = params[:session_id]
#     session = Stripe::Checkout::Session.retrieve(session_id)

#     if session.payment_status == 'paid'
#       current_user.update!(
#         is_premium: true,
#         stripe_subscription_id: session.subscription
#       )
#       flash[:success] = "Ab aap Premium user ho!"
#     else
#       flash[:alert] = "Payment complete nahi hua."
#     end

#     redirect_to all_jobs_path
#   end

#   def cancel
#     flash[:notice] = "Payment cancelled hua."
#     redirect_to pricing_path
#   end
# end

class SubscriptionsController < ApplicationController # rubocop:disable Style/Documentation
  before_action :require_login

  def plan_details
    # binding.irb
    @plan_detail = Plan.first
    @subscription_plan_detail = Subscription.find_by(user_id: current_user.id)
    # if @subscription_plan_detail.present?

    # else

    # end
  end

  def new # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    if current_user.stripe_customer_id.blank?
      stripe_customer = Stripe::Customer.create(
        name: current_user.username,
        email: current_user.email
      )
      current_user.update!(stripe_customer_id: stripe_customer.id)
    end

    payment_intent = Stripe::PaymentIntent.create(
      amount: 49_900,
      currency: 'inr',
      customer: current_user.stripe_customer_id,
      setup_future_usage: 'off_session'
    )

    @client_secret = payment_intent.client_secret
  rescue Stripe::StripeError => e
    flash[:alert] = "Payment setup failed: #{e.message}"
    redirect_to pricing_path
  end

  def success # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    payment_intent_id = params[:payment_intent]
    pi = Stripe::PaymentIntent.retrieve(payment_intent_id)
    if pi.status == 'succeeded'
      current_user.update!(is_premium: true, stripe_payment_intent_id: pi.id,
                           stripe_payment_method_id: pi.payment_method)
      plan_details = Plan.first

      price = Stripe::Price.create({
                                     currency: 'usd',
                                     unit_amount: plan_details.plan_price,
                                     recurring: { interval: 'month' },
                                     product_data: { name: plan_details.plan_name }
                                   })

      subscription = Stripe::Subscription.create({
                                                   customer: current_user.stripe_customer_id,
                                                   items: [{ price: price.id }],
                                                   default_payment_method: pi.payment_method
                                                 })

      local_subscription = Subscription.find_or_initialize_by(user_id: current_user.id)
      local_subscription.update(
        stripe_subscription_id: subscription.id,
        status: subscription.status,
        started_at: Time.at(subscription.start_date),
        ended_at: Time.at(subscription.start_date) + 30.days,
        price_cents: subscription.plan.amount
      )
      current_user.update(stripe_subscription_id: subscription.id)
      flash[:success] = 'Subscription activated!'
      redirect_to all_jobs_path
    else
      flash[:alert] = 'Payment not completed.'
      redirect_to pricing_path
    end
  rescue Stripe::StripeError => e
    flash[:alert] = e.message
    redirect_to pricing_path
  end

  def cancel
    flash[:notice] = 'Payment cancelled.'
    redirect_to pricing_path
  end
end

# frozen_string_literal: true

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError
      render json: { error: 'Invalid payload' }, status: 400 and return
    rescue Stripe::SignatureVerificationError
      render json: { error: 'Invalid signature' }, status: 400 and return
    end

    case event.type
    when 'customer.subscription.created', 'customer.subscription.updated'
      handle_subscription_update(event.data.object)
    when 'customer.subscription.deleted'
      handle_subscription_deleted(event.data.object)
    else
      Rails.logger.info("Unhandled event type: #{event.type}")
    end

    render json: { message: 'success' }
  end

  private

  def handle_subscription_update(sub)
    local_sub = Subscription.find_by(stripe_subscription_id: sub.id)
    return unless local_sub

    local_sub.update!(
      status: sub.status,
      ended_at: sub.ended_at ? Time.at(sub.ended_at) : nil
    )
  end

  def handle_subscription_deleted(sub)
    local_sub = Subscription.find_by(stripe_subscription_id: sub.id)
    return unless local_sub

    local_sub.update!(
      status: 'canceled',
      ended_at: sub.ended_at ? Time.at(sub.ended_at) : Time.current
    )
  end
end

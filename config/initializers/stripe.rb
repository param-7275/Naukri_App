# frozen_string_literal: true

Stripe.api_key = Rails.application.credentials.stripe[:secret_key]

Rails.configuration.stripe = {
  publishable_key: Rails.application.credentials.stripe[:public_key],
  secret_key: Rails.application.credentials.stripe[:secret_key]
}

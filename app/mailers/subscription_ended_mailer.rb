# frozen_string_literal: true

class SubscriptionEndedMailer < ApplicationMailer # rubocop:disable Style/Documentation
  default from: 'paramjeet@poplify.com'

  def subscription_end(subscription, user, plan)
    @subscription = subscription
    @user = user
    @plan = plan

    # Example: link to subscription or dashboard
    # @url = edit_subscription_url(@subscription, host: "localhost:3000")

    mail(
      to: @user.email,
      subject: 'Your subscription has ended'
    )
  end
end

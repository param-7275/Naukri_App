# frozen_string_literal: true

class PremiumEndJob
  include Sidekiq::Job

  def perform
    Subscription.includes(:user)
                .where('ended_at <= ?', Time.current)
                .find_each do |subscription|
      user = subscription.user
      next unless user&.is_premium?

      subscription.update(status: 'Inactive')
      user.update(is_premium: false)
      plan = Plan.first
      # Send Subscription End Mail
      SubscriptionEndedMailer.subscription_end(subscription, user, plan).deliver_later
    end
  end
end

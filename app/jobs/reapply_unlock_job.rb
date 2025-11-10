# frozen_string_literal: true

class ReapplyUnlockJob
  include Sidekiq::Job

  def perform
    JobApplication.where(status: 'reject', reapply_allowed: false)
                  .where('rejected_at <= ?', 3.months.ago)
                  .find_each do |job_application|
      job_application.update(reapply_allowed: true)

      JobReapplyNotificationMailer.reapply_available(job_application).deliver_later
    end
  end
end

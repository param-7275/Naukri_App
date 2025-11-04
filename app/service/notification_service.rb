class NotificationService
  def self.send_expiry_notification(user, job_app)
    JobNotificationCleanupMailer.again_apply(user, job_app).deliver_later
  end
end

class NotificationMailer < ApplicationMailer
  default from: "paramjeet@poplify.com"

  def job_posted(user, job)
    return unless job.present?

    @user = user
    @job = job
    mail(to: @user.email, subject: "New Job Posted: #{@job.title}")
  end
end

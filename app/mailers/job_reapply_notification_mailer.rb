# frozen_string_literal: true

class JobReapplyNotificationMailer < ApplicationMailer
  default from: 'paramjeet@poplify.com'

  def reapply_available(job_application)
    @job_application = job_application
    @user = @job_application.jobseeker
    @job = @job_application.job

    @url = edit_reapply_application_url(id: @job_application.id, host: 'localhost:3000')

    mail(
      to: @user.email,
      subject: "You can reapply for #{@job.title}"
    )
  end
end

class JobsController < ApplicationController
  before_action :ensure_recruiter!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_job, only: [:show, :edit, :update, :destroy]

  def index
    @recruiter_jobs = Job.where(recruiter_id: current_user.id)
  end

  def applicants
    @applications = JobApplication.joins(:job)
          .where(jobs: { recruiter_id: current_user.id })
          .includes(:job, :jobseeker)
          .order(created_at: :desc)
  end
    
  def recruiter_index
  end

  def change_application_status
    @job = JobApplication.find_by(id: params[:id])
    if @job.present?
      @job.update(status: params[:status])
      redirect_to change_job_status_path
    end
  end


  def show
  end

  def new
    @job = current_user.jobs.build
  end

  def create
    @job = current_user.jobs.build(job_params)
    if @job.save
      redirect_to recruiter_jobs_path, notice: "Job posted."
    else
      render :new
    end
  end

  def edit; end

  def update
    if @job.update!(job_params)
      redirect_to recruiter_jobs_path, notice: "Job Updated."
    else
      render :edit
    end
  end

  def destroy
    @job.destroy
    redirect_to recruiter_jobs_path, notice: "Deleted."
  end

  private

  def set_job
    @job = Job.find_by(id: params[:id])
  end

  def job_params
    params.require(:job).permit(:title, :description, :company_name, :location, :industry_type, :vacancy)
  end

  def ensure_recruiter!
    redirect_to root_path, alert: "Access denied" unless current_user&.recruiter?
  end
end

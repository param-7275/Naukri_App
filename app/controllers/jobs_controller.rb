class JobsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :ensure_recruiter!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_job, only: [:show, :edit, :update, :destroy]

  def index
    @jobs = Job.all.order(created_at: :desc)
  end

  def show
  end

  def new
    @job = current_user.jobs.build
  end

  def create
    @job = current_user.jobs.build(job_params)
    if @job.save
      redirect_to @job, notice: "Job posted."
    else
      render :new
    end
  end

  def edit; end

  def update
    if @job.update(job_params)
      redirect_to @job, notice: "Updated."
    else
      render :edit
    end
  end

  def destroy
    @job.destroy
    redirect_to jobs_path, notice: "Deleted."
  end

  private

  def set_job
    @job = Job.find(params[:id])
  end

  def job_params
    params.require(:job).permit(:title, :description, :location, :salary)
  end

  def ensure_recruiter!
    redirect_to root_path, alert: "Access denied" unless current_user&.recruiter?
  end
end

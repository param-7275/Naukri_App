class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    # for admin or recruiter to see all users (optional)
    @users = User.all
  end

  def show
    @user = current_user
  end
end

# frozen_string_literal: true

class UsersController < ApplicationController
  def new_signup
    @user = User.new
  end

  def user_signup
    user_role = user_params[:role]
    allowed_roles = User.roles.keys
    unless allowed_roles.include?(user_role)
      flash.now[:error] = 'Role is invalid.'
      @user = User.new
      render :new_signup, status: :unprocessable_entity and return
    end
    @user = User.new(user_params)

    if @user.save
      flash[:success] = 'Account successfully created. Please log in.'
      redirect_to login_path
    else
      flash.now[:error] = @user.errors.full_messages
      render :new_signup, status: :unprocessable_entity
    end
  end

  def new_login
    @user = User.new
  end

  def user_login
    email_param = params.dig(:user, :email) || params[:email]
    password_param = params.dig(:user, :password) || params[:password]
    @user = User.find_by(email: email_param)

    if @user&.valid_password?(password_param)
      session[:user_id] = @user.id
      flash[:success] = 'Login successfully!'

      redirect_path = case @user.role
                      when 'recruiter' then recruiter_home_path
                      when 'jobseeker' then jobseeker_home_path
                      else root_path
                      end

      redirect_to redirect_path
    else
      flash.now[:error] = 'Invalid email or password'
      render :new_login, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:success] = 'Successfully logged out.'
    redirect_to login_path
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :phone_number, :password, :password_confirmation, :role,
                                 :is_premium)
  end
end

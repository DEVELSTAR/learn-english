class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  def new
    redirect_to root_path if authenticated?
    @user = User.new
  end

  def create
    @user = User.new(registration_params)
    @user.role = :student # Always register as student

    if @user.save
      start_new_session_for @user
      redirect_to root_path, notice: "Welcome to Learn English! You are now signed up."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:name, :email_address, :password, :password_confirmation)
  end
end


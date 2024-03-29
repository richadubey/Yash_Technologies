class UsersController < ApplicationController
  before_action :set_user, only: [:update]

  def create
    @user = User.new(user_params)
    if @user.save
      notify_third_party_apis(@user)
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      notify_third_party_apis(@user)
      render json: @user, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def notify_third_party_apis(user_data_change)

  end

end

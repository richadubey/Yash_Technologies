class UsersController < ApplicationController
  before_action :set_user, only: [:update]

  JWT_SECRET = "679441d1edf3bd9ac4e7ab31f8c1034e845c2f83743c9e3c8fbb639708d539a6"
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
    jwt_payload = { user_id: user_data_change.id }
    jwt_token = JWT.encode(jwt_payload, JWT_SECRET, 'HS256')
    begin
      response = RestClient.get('http://localhost:3001/movies', { Authorization: "Bearer #{jwt_token}" })
      puts "Notification sent successfully! Response: #{response}" 
    rescue RestClient::ExceptionWithResponse => e
      puts "Failed to send notification: #{e.response}"
    rescue RestClient::Exception, Errno::ECONNREFUSED => e
      puts "Failed to send notification: #{e.message}"
    end

  end

end

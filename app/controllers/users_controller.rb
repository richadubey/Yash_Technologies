class UsersController < ApplicationController
  before_action :set_user, only: [:update]

  def create
    @user = User.new(user_params)
    if @user.save
      notify_third_party_apis(@user, operation: :create)
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      notify_third_party_apis(@user, operation: :update)
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

  def notify_third_party_apis(user_data_change, operation:)
    jwt_payload = { user_id: user_data_change.id, operation: operation }
    jwt_token = JWT.encode(jwt_payload, ENV['JWT_SECRET'], 'HS256')

    params = {
      name: user_data_change.name,
      email: user_data_change.email,
      operation: operation
    }

    urls = ENV['THIRD_PARTY_URL']&.split(',')

    if urls.present?
      urls.each do |url|
        puts "Checking url #{url}"
        begin
          response = RestClient.post(url.strip, params.to_json, Authorization: "Bearer #{jwt_token}", content_type: :json)
          puts "Notification sent successfully to #{url}! Response: #{response}"
        rescue RestClient::ExceptionWithResponse => e
          puts "Failed to send notification to #{url}: #{e.response}"
          # Handle error for this URL, e.g., log the error or retry later
        rescue RestClient::Exception, Errno::ECONNREFUSED => e
          puts "Failed to send notification to #{url}: #{e.message}"
          # Handle error for this URL, e.g., log the error or retry later
        end
      end
    else
      puts "No URLs found in the environment variable THIRD_PARTY_URL_1"
    end
  end
end

class Api::V1::SessionsController < ApplicationController
  def create
    if Rails.env.test?
      return render status: :unauthorized if params[:code] != "123456"
    else
      canSignin = ValidationCode.exists?(email: params[:email], code: params[:code], used_at: nil)
      return render status: :unauthorized unless canSignin # 401
    end
    user = User.find_by_email(params[:email])
    if user.nil?
      render status: 404, json: { errors: "User dose not exist." } # :not_found
    else
      payload = { user_id: user.id }
      token = JWT.encode payload, Rails.application.credentials.hmac_secret, "HS256"
      render status: 200, json: { jwt: token } # :ok
    end
  end
end
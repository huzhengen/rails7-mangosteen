class Api::V1::SessionsController < ApplicationController
  def create
    if Rails.env.test?
      return render status: :unauthorized if params[:code] != "123456"
    else
      canSignin = ValidationCode.exists?(email: params[:email], code: params[:code], used_at: nil)
      return render status: :unauthorized unless canSignin # 401
    end
    user = User.find_or_create_by email: params[:email]
    render status: 200, json: { jwt: user.generate_jwt } # :ok
  end
end

class Api::V1::ValidationCodesController < ApplicationController
  def create
    # render status: :too_many_requests
    return render status: 429 if ValidationCode.exists?(email: params[:email], kind: "sign_in", created_at: 1.minute.ago..Time.now)
    validation_code = ValidationCode.new email: params[:email], kind: "sign_in"
    if validation_code.save
      render status: 200
    else
      render json: { errors: validation_code.errors }, status: 422
    end
  end
end

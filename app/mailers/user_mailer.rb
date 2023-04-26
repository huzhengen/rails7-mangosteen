class UserMailer < ApplicationMailer
  def welcome_email(email)
    validation_code = ValidationCode.order(created_at: :desc).find_by_email(email)
    @code = validation_code.code
    mail(to: email, subject: "【#{@code}】时空存钱罐验证码")
  end
end

class UserMailer < ApplicationMailer
  def welcome_email(code, email)
    @code = code
    @email = email
    mail(to: email, subject: "Welcome to My Awesome Site")
  end
end

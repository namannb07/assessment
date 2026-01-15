module Validator
  PASSWORD_REGEX = /\A(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&+=]).{8,}\z/

  def validate_email(email)
    return email =~ URI::MailTo::EMAIL_REGEXP || email == nil
  end

  def validate_password(password)
    return password.match?(PASSWORD_REGEX) || password == nil
  end
end
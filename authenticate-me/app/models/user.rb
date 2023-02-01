class User < ApplicationRecord
  has_secure_password
  validates :username, :email, :session_token, presence: true, uniqueness: true
  validates :username, length: { in: 3..30 }
  validates :username, format: { without: URI::MailTo::EMAIL_REGEXP, message: "can't be an email" }
  validates :email, length: { in: 3..255 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email"}
  validates :password, length: { in: 6..255 }, allow_nil: true

  before_validation :ensure_session_token
  
  def reset_session_token!
    self.session_token = generate_unique_session_token
    self.save!
    session_token
  end

  def self.find_by_credentials(credential, password)
    if URI::MailTo::EMAIL_REGEXP.match?(credential)
      user = User.find_by(email: credential)
    else
      user = User.find_by(username: credential)
    end

    if user&.authenticate(password)
      return user
    else
      nil
    end
  end

  private

  def generate_unique_session_token
    while true
      token = SecureRandom.urlsafe_base64
      return token unless User.exists?(session_token: token)
    end
  end

  def ensure_session_token
    self.session_token ||= generate_unique_session_token
  end


end

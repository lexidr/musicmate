class JwtService
  ALGORITHM = "HS256"
  TOKEN_LIFETIME = 7.days

  def self.encode(user)
    now = Time.current
    payload = {
      sub: user.id,
      iat: now.to_i,
      exp: (now + TOKEN_LIFETIME).to_i
    }

    JWT.encode(payload, secret, ALGORITHM)
  end

  def self.user_from(token)
    return if token.blank?

    payload = JWT.decode(token, secret, true, algorithm: ALGORITHM).first
    User.find_by(id: payload["sub"])
  rescue JWT::DecodeError
    nil
  end

  def self.secret
    ENV.fetch("JWT_SECRET")
  end

  private_class_method :secret
end

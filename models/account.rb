class Account < ActiveRecord::Base
  attr_accessor :password, :password_confirmation

  validates_presence_of     :email, :role
  validates_presence_of     :password,                   if: :password_required
  validates_presence_of     :password_confirmation,      if: :password_required
  validates_length_of       :password, within: 4..40,    if: :password_required
  validates_confirmation_of :password,                   if: :password_required
  validates_length_of       :email,    within: 3..100
  validates_uniqueness_of   :email,    case_sensitive: false
  validates_format_of       :email,    with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_format_of       :role,     with: /[A-Za-z]/

  before_save :encrypt_password, if: :password_required

  def self.authenticate(email, password)
    account = first(conditions: ['lower(email) = lower(?)', email]) if email.present? && password.present?
    account&.password?(password) ? account : nil
  end

  def password?(password)
    ::BCrypt::Password.new(crypted_password) == password
  end

  private

  def encrypt_password
    value = ::BCrypt::Password.create(password)
    value = value.force_encoding(Encoding::UTF_8) if value.encoding == Encoding::ASCII_8BIT
    self.crypted_password = value
  end

  def password_required
    crypted_password.blank? || password.present?
  end
end

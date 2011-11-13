# encoding: utf-8
class User < ActiveRecord::Base
  ROLES = ['admin', 'agent', 'user']
  has_many :places
  attr_accessible :name, :role, :phone,:email, :password, :password_confirmation
  attr_accessor :password
  before_save :encrypt_password
  
  validates_confirmation_of :password, :message => "Пароли должны совпадать"
  validates_presence_of :password, :on => :create
  validates_presence_of :email, :message => "Укажите email"
  validates_presence_of :name, :message => "Укажите ваше имя"
#  validates :role, :inclusion => { :in => %w(admin agent user) }
  validates_uniqueness_of :email, :message => "Пользователь с таким email уже зарегистрирован"
  validates_uniqueness_of :phone, :message => "Пользователь с таким номером телефона уже зарегистрирован"
  
  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
  
  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password_hash == BCrypt::Engine.hash_secret( password, user.password_salt)
      user
    else
      nil
    end
  end
  
end
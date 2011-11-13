# encoding: utf-8
class ApplicationController < ActionController::Base
  class AuthException < StandardError; end
  protect_from_forgery
  helper_method :current_user, :authenticate!
  rescue_from AuthException, :with => :auth_exception
  

  def auth_exception(exception)
    redirect_to root_url, :notice => "Вы незарегистрированы или вы не агент."
  end
  
  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def authenticate!
    if current_user.nil?
      raise AuthException
    elsif !(%w(admin agent).include?(current_user.role))
      raise AuthException
    else
      true
    end
  end
end

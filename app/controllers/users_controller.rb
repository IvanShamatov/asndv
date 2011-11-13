# encoding: utf-8
class UsersController < ApplicationController
  def index
    @users = User.all
  end
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.role = 'user' if @user.role.blank? || !User::ROLES.include?(@user.role)
    if @user.save
      session[:user_id] = User.find_by_email(@user.email).id
      redirect_to root_url, :notice => 'Зарегистрировались успешно!'
    else
      render 'new'
    end
  end

  def destroy
  end

  def profile
    @user = current_user
    @places = current_user.places
  end

end

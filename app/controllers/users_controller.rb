# encoding: utf-8
class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to root_url, :notice => 'Зарегистрировались успешно!'
    else
      render 'new'
    end
  end

  def destroy
  end

end

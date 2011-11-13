# encoding: utf-8
class PlacesController < ApplicationController
  before_filter :authenticate!, :only => [:new, :edit, :create, :destroy]

  def as_table
    @places = Place.all
  end
  
  def index
    # if params[:search]
    #   @places = Place.where("address LIKE '%#{params[:address]}%' and metro = '#{params[:metro]}' and num_rooms in #{params[:num_rooms]} and price < '#{params[:price]}'") 
    # else
    #   @places = Place.all
    # end
    @places = Place.all
    @gmaps_places = @places.to_gmaps4rails
  end

  def show
    @place = Place.find(params[:id])
  end

  def new
    @place = Place.new
  end

  def edit
    @place = Place.find(params[:id])
  end

  def create
    @place = Place.new(params[:place])
    current_user.places << @place
    if @place.save
      redirect_to(@place, :notice => 'Место было добавлено.')
    else
      render :action => "new"
    end
  end

  def update
    @place = Place.find(params[:id])
    if @place.update_attributes(params[:place])
      redirect_to(@place, :notice => 'Данные о месте обновились.') 
    else
        render :action => "edit" 
    end
  end

  def destroy
    @place = Place.find(params[:id])
    if current_user.role == 'admin' or current_user.places.include?(@place.id)
      @place.destroy
      redirect_to(places_url)
    else
      redirect_to root_url, :message => "Вы не админ и не агент этого места, нечего вам его и удалять"
    end
  end
  
end

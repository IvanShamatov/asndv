# encoding: utf-8
class Place < ActiveRecord::Base
  acts_as_gmappable :check_process => :prevent_geocoding
  belongs_to :user
  before_save :geocode_address
  attr_accessible :address, :description, :metro, :size, :num_rooms, :price
  validates :address, :size, :num_rooms, :price, :presence => true
  METRO = "Девяткино,Гражданский проспект,Академическая,Политехническая,Площадь Мужества,Лесная,Выборгская,Площадь Ленина,Чернышевская,Площадь Восстания,Владимирская,Пушкинская,Технологический институт,Балтийская,Нарвская,Кировский завод,Автово,Ленинский проспект,Проспект Ветеранов,Парнас,Проспект Просвещения,Озерки,Удельная,Пионерская,Чёрная речка,Петроградская,Горьковская,Невский проспект,Сенная площадь,Технологический институт,Фрунзенская,Московские ворота,Электросила,Парк Победы,Московская,Звёздная,Купчино,Приморская,Василеостровская,Гостиный двор,Маяковская,Площадь Александра,Невского-1,Елизаровская,Ломоносовская,Пролетарская,Обухово,Рыбацкое,Спасская,Достоевская,Лиговский проспект,Площадь Александра Невского-2,Новочеркасская,Ладожская,Проспект Большевиков,Улица Дыбенко,Комендантский проспект,Старая Деревня,Крестовский остров,Чкаловская,Спортивная,Адмиралтейская,Садовая,Звенигородская,Обводный канал,Волковская".split(',').sort!

  def prevent_geocoding
    address.blank?
  end

  def geocode_address
    geodata = Gmaps4rails.geocode(self.address)
    if geodata
      geodata = geodata.first
      self.latitude = geodata[:lat]
      self.longitude = geodata[:lng]
      self.gmaps = true
    end
  end

  def gmaps4rails_address
    self.address 
  end
  
  def gmaps4rails_infowindow
    "<strong>#{self.address}</strong><p>#{self.description}. #{self.size} кв.м. за #{self.price} в месяц</p><p>#{self.agent_data}</p>"
  end

  def agent_data
    "#{self.user.name}, #{self.user.phone} или #{self.user.email} для связи"
  end
end

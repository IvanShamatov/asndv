class CreatePlaces < ActiveRecord::Migration
  def self.up
    create_table :places do |t|
      t.string :address
      t.float :latitude
      t.float :longitude
      t.boolean :gmaps

      t.timestamps
    end
  end

  def self.down
    drop_table :places
  end
end

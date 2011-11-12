class AddColumnsToPlace < ActiveRecord::Migration
  def self.up
    add_column :places, :pics, :string
    add_column :places, :metro, :string
    add_column :places, :price, :decimal
    add_column :places, :size, :float
    add_column :places, :district, :string
    add_column :places, :description, :text
    add_column :places, :num_rooms, :integer
  end

  def self.down
  end
end

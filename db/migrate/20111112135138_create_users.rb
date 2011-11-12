class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email
      t.string :name
      t.string :password_hash
      t.string :password_salt
      t.string :phone
      t.string :role

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end

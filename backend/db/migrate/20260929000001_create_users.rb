class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email
      t.string :spotify_user_id, null: false
      t.string :avatar_url

      t.timestamps
    end

    add_index :users, :spotify_user_id, unique: true
  end
end

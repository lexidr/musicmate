class CreateProfileItems < ActiveRecord::Migration[8.1]
  def change
    create_table :profile_items do |t|
      t.references :music_profile, null: false, foreign_key: true
      t.string :item_type, null: false
      t.string :name, null: false
      t.string :artist_name
      t.string :spotify_id, null: false
      t.string :spotify_url
      t.string :image_url
      t.integer :weight, null: false
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :profile_items, [:music_profile_id, :item_type]
  end
end

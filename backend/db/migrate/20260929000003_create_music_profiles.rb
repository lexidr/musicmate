class CreateMusicProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :music_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :status, null: false, default: "empty"
      t.integer :tracks_count, null: false, default: 0
      t.integer :artists_count, null: false, default: 0

      t.timestamps
    end
  end
end

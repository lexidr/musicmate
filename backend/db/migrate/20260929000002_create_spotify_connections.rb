class CreateSpotifyConnections < ActiveRecord::Migration[8.1]
  def change
    create_table :spotify_connections do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.text :access_token, null: false
      t.text :refresh_token
      t.datetime :token_expires_at
      t.string :scopes

      t.timestamps
    end
  end
end

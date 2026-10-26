class CreateComparisons < ActiveRecord::Migration[8.1]
  def change
    create_table :comparisons do |t|
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.references :guest, null: true, foreign_key: { to_table: :users }
      t.string :invite_token, null: false
      t.string :status, null: false, default: "waiting"
      t.integer :score

      t.timestamps
    end

    add_index :comparisons, :invite_token, unique: true
  end
end

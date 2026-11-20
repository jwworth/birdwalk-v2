class CreateChallenges < ActiveRecord::Migration[8.1]
  def change
    create_table :challenges do |t|
      t.references :location, null: false, foreign_key: true, index: { unique: true }
      t.integer :rotation_position, null: false

      t.timestamps
    end

    add_index :challenges, :rotation_position, unique: true
    add_check_constraint :challenges, "rotation_position > 0", name: "challenges_rotation_position_positive"
  end
end

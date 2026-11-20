class CreateRounds < ActiveRecord::Migration[8.1]
  def change
    create_table :rounds do |t|
      t.references :challenge, null: false, foreign_key: true
      t.integer :position, null: false
      t.references :correct_bird, foreign_key: { to_table: :birds }
      t.references :first_distractor, foreign_key: { to_table: :birds }
      t.references :second_distractor, foreign_key: { to_table: :birds }
      t.references :third_distractor, foreign_key: { to_table: :birds }

      t.timestamps
    end

    add_index :rounds, [ :challenge_id, :position ], unique: true
    add_check_constraint :rounds, "position BETWEEN 1 AND 5", name: "rounds_position_range"

    # Comparisons with NULL are not false, so partially filled rounds pass.
    add_check_constraint :rounds, <<~SQL.squish, name: "rounds_distinct_birds"
      correct_bird_id <> first_distractor_id AND
      correct_bird_id <> second_distractor_id AND
      correct_bird_id <> third_distractor_id AND
      first_distractor_id <> second_distractor_id AND
      first_distractor_id <> third_distractor_id AND
      second_distractor_id <> third_distractor_id
    SQL
  end
end

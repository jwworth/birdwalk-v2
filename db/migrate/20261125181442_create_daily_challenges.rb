class CreateDailyChallenges < ActiveRecord::Migration[8.1]
  def change
    create_table :daily_challenges do |t|
      t.date :date, null: false, index: { unique: true }
      t.references :challenge, null: false, foreign_key: true

      t.timestamps
    end
  end
end

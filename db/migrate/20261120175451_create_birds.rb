class CreateBirds < ActiveRecord::Migration[8.1]
  def change
    create_table :birds do |t|
      t.string :common_name, null: false
      t.string :scientific_name, null: false

      t.timestamps
    end

    add_index :birds, "lower(common_name)", unique: true
    add_index :birds, "lower(scientific_name)", unique: true
  end
end

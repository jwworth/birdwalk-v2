class CreateLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :locations do |t|
      t.string :name, null: false
      t.string :state, null: false

      t.timestamps
    end

    add_index :locations, "lower(name), state", unique: true, name: "index_locations_on_lower_name_and_state"
  end
end

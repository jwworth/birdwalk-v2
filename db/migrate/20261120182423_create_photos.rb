class CreatePhotos < ActiveRecord::Migration[8.1]
  def change
    create_table :photos do |t|
      t.references :bird, null: false, foreign_key: true
      t.string :source_url, null: false
      t.string :creator, null: false
      t.string :license_name, null: false
      t.string :license_url, null: false
      t.text :attribution_notes

      t.timestamps
    end
  end
end

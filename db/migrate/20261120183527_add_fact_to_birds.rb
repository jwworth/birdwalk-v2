class AddFactToBirds < ActiveRecord::Migration[8.1]
  def change
    add_column :birds, :fact, :text
  end
end

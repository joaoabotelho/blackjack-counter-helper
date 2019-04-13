class CreatePlays < ActiveRecord::Migration[5.2]
  def change
    create_table :plays do |t|
      t.string :hand
      t.integer :dealer_hand
      t.string :play

      t.timestamps
    end
  end
end

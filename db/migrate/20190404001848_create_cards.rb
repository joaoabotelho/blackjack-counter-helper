class CreateCards < ActiveRecord::Migration[5.2]
  def change
    create_table :cards do |t|
      t.string :symbol
      t.integer :value
      t.integer :true_value

      t.timestamps
    end
  end
end

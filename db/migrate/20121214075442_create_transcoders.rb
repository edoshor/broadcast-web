class CreateTranscoders < ActiveRecord::Migration
  def change
    create_table :transcoders do |t|
      t.string :key
      t.string :host, limit: 15
      t.integer :port

      t.timestamps
    end
  end
end

class CreateTranscoders < ActiveRecord::Migration
  def change
    create_table :transcoders do |t|
      t.string :host, limit: 15
      t.integer :port
      t.integer :status_port
      t.boolean :master
      t.boolean :slave

      t.timestamps
    end
  end
end

class CreateSignalSources < ActiveRecord::Migration
  def change
    create_table :signal_sources do |t|
      t.string :name
      t.string :ip, limit: 15
      t.integer :port

      t.timestamps
    end
  end
end

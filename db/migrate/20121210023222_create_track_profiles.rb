class CreateTrackProfiles < ActiveRecord::Migration
  def change
    create_table :track_profiles do |t|
      t.integer :profile_number
      t.integer :num_channels
      t.integer :gain
      t.references :preset

      t.timestamps
    end
    add_index :track_profiles, :preset_id
  end
end

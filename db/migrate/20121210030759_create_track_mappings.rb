class CreateTrackMappings < ActiveRecord::Migration
  def change
    create_table :track_mappings do |t|
      t.references :preset
      t.references :track_profile
      t.integer :input_track

      t.timestamps
    end
    add_index :track_mappings, :preset_id
    add_index :track_mappings, :track_profile_id
  end
end

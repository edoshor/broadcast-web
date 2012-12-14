class Preset < ActiveRecord::Base
  after_find :prepare_arguments
  after_save :prepare_arguments

  attr_accessible :name, :track_profiles_attributes, :track_mappings_attributes

  has_many :track_profiles, :dependent => :destroy
  has_many :track_mappings, :dependent => :destroy

  accepts_nested_attributes_for :track_profiles, :track_mappings

  def as_args
    @args
  end
  
  def audio_mappings
    @mappings
  end

  private
  def prepare_arguments
    tracks = track_profiles.map {|trk| trk.to_a}
    @args = {force: 1, tracks_cnt: tracks.length, tracks: tracks}
    @mappings = track_profiles.map {|trk| track_mappings.where(track_profile_id: trk)[0].input_track}
  end

end

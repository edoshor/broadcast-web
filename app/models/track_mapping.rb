class TrackMapping < ActiveRecord::Base
  belongs_to :preset
  belongs_to :track_profile
  attr_accessible :input_track
end

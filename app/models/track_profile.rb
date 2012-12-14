class TrackProfile < ActiveRecord::Base
  belongs_to :preset
  attr_accessible :gain, :num_channels, :profile_number

  def to_a
    [profile_number, num_channels, gain, 0]
  end
end

require 'spec_helper'

describe Preset do
  it "has valid factory" do
    FactoryGirl.create(:preset).should be_valid
  end

  it "prepares arguments after save" do
    preset = FactoryGirl.create(:preset)

    mapping = preset.track_mappings.create({input_track: 0})
    mapping.track_profile = preset.track_profiles.create({profile_number: 1, num_channels: 0, gain: 0})
    mapping.save!
    mapping = preset.track_mappings.create({input_track: 2})
    mapping.track_profile = preset.track_profiles.create({profile_number: 101, num_channels: 2, gain: 20})
    mapping.save!

    preset.save!

    args = preset.as_args()
    args.should_not be_empty
    args[:force].should_not be_nil
    args[:tracks_cnt].should == 2
    args[:tracks].should eq [[1, 0, 0, 0], [101, 2, 20, 0]]

    audio_mappings = preset.audio_mappings()
    audio_mappings.should_not be_empty
    audio_mappings.should eq [0, 2]
  end

end

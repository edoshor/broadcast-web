require 'spec_helper'

describe Transcoder do

  it "has a valid factory" do
    FactoryGirl.create(:transcoder).should be_valid
  end

  it "initialize api after find" do
    transcoder = FactoryGirl.create(:transcoder)
    transcoder = Transcoder.find(transcoder.id)
    transcoder.api.host.should eq transcoder.host
    transcoder.api.port.should eq transcoder.port
  end

  it "creates slot preset" do
    transcoder = FactoryGirl.create(:transcoder)
    preset = FactoryGirl.create(:preset)
    transcoder.create_slot(1, preset)
    SlotPreset.where(transcoder_id: transcoder).count.should == 1
  end

  it "removes slot preset" do
    transcoder = FactoryGirl.create(:transcoder)
    preset = FactoryGirl.create(:preset)
    transcoder.create_slot(1, preset)
    transcoder.remove_slot(1)
    SlotPreset.where(transcoder_id: transcoder).should be_empty
  end

  it "finds slot preset" do
    transcoder = FactoryGirl.create(:transcoder)
    preset = FactoryGirl.create(:preset)
    transcoder.create_slot(1, preset)
    transcoder.slot_preset(1).should eq preset
  end

end

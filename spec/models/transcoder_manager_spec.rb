require 'spec_helper'

describe TranscoderManager do

  instance = TranscoderManager.instance

  describe "#has_source?" do
    it "has known signal source" do
      instance.has_source?('source1').should == true
    end

    it "has not unknown signal source" do
      instance.has_source?('source1123').should == false
    end
  end

  describe "#get_source" do
    it "is nil when unknown signal source" do
      instance.get_source('source1123').should be_nil
    end

    it "is requested signal source" do
      source = instance.get_source('source1')
      source.should eq(SignalSource.find_by_name 'source1')
    end
  end

  describe "#get_source_by_address" do
    it "is nil when unknown signal source" do
      instance.get_source_by_address('0.0.0.0',1234).should be_nil
    end

    it "is requested signal source" do
      source = instance.get_source('source1')
      source = instance.get_source_by_address(source.ip, source.port)
      source.should eq(SignalSource.find_by_name 'source1')
    end
  end

  describe "#has_preset?" do
    it "has known preset" do
      instance.has_preset?('preset1').should == true
    end

    it "has not unknown preset" do
      instance.has_preset?('preset1123').should == false
    end
  end

  describe "#get_preset" do
    it "is nil when unknown preset" do
      instance.get_preset('preset1123').should be_nil
    end

    it "is requested preset" do
      preset = instance.get_preset('preset1')
      preset.should eq(Preset.find_by_name 'preset1')
    end
  end

  describe "#random_preset" do
    it "always return a preset" do
      [1..10].each do
        instance.random_preset.should_not be_nil
      end
    end
  end

end

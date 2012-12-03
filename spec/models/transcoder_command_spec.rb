require 'spec_helper'

describe TranscoderCommand do

  describe "#validate" do

    it "transcoder save" do
      TranscoderCommand.new("cmd", TranscoderCommand::TRANSCODER_SAVE, [])
      .validate.should eq("valid")
    end

    it "transcoder reset" do
      TranscoderCommand.new("cmd", TranscoderCommand::TRANSCODER_RESET, [])
      .validate.should eq("valid")
    end

    it "transcoder status" do
      TranscoderCommand.new("cmd", TranscoderCommand::TRANSCODER_STATUS, [])
      .validate.should eq("valid")
    end

    it "create slot - preset, single slot" do
      TranscoderCommand.new("cmd", TranscoderCommand::SLOT_CREATE, %w(preset1 1))
      .validate.should eq("valid")
    end

    it "create slot - preset, slot range" do
      TranscoderCommand.new("cmd", TranscoderCommand::SLOT_CREATE, %w(preset1 1 5))
      .validate.should eq("valid")
    end

    it "create slot - auto preset, single slot" do
      TranscoderCommand.new("cmd", TranscoderCommand::SLOT_CREATE, %w(auto 1))
      .validate.should eq("valid")
    end

    it "create slot - auto preset, slot range" do
      TranscoderCommand.new("cmd", TranscoderCommand::SLOT_CREATE, %w(auto 1 5))
      .validate.should eq("valid")
    end

    it "delete slot - single slot" do
      TranscoderCommand.new("cmd", TranscoderCommand::SLOT_DELETE, %w(1))
      .validate.should eq("valid")
    end

    it "delete slot - slot range" do
      TranscoderCommand.new("cmd", TranscoderCommand::SLOT_DELETE, %w(1 5))
      .validate.should eq("valid")
    end

    it "delete slot - all slots" do
      TranscoderCommand.new("cmd", TranscoderCommand::SLOT_DELETE, %w(all))
      .validate.should eq("valid")
    end

    it "start slot - source, single slot" do
      TranscoderCommand.new("cmd", TranscoderCommand::SLOT_START, %w(Source1 1))
      .validate.should eq("valid")
    end

    it "start slot - source, slot range" do
      TranscoderCommand.new("cmd", TranscoderCommand::SLOT_START, %w(Source1 1 5))
      .validate.should eq("valid")
    end

    it "stop slot - single slot" do
      TranscoderCommand.new("cmd", TranscoderCommand::SLOT_STOP, %w(1))
      .validate.should eq("valid")
    end

    it "stop slot - slot range" do
      TranscoderCommand.new("cmd", TranscoderCommand::SLOT_STOP, %w(1 5))
      .validate.should eq("valid")
    end

    it "stop slot - all slots" do
      TranscoderCommand.new("cmd", TranscoderCommand::SLOT_STOP, %w(all))
      .validate.should eq("valid")
    end

    it "unknown command" do
      TranscoderCommand.new("cmd", TranscoderCommand::UNKNOWN_COMMAND, [])
      .validate.should eq("unknown command")
    end

    it "create slot - no args" do
      TranscoderCommand.new("cmd", TranscoderCommand::SLOT_CREATE, [])
      .validate.should eq("not enough arguments")
    end

    it "create slot - 1 argument" do
      TranscoderCommand.new("cmd", TranscoderCommand::SLOT_CREATE, %w(preset1))
      .validate.should eq("not enough arguments")
    end

    it "delete slot - no args" do
      TranscoderCommand.new("cmd", TranscoderCommand::SLOT_DELETE, [])
      .validate.should eq("not enough arguments")
    end

    it "start slot - no args" do
      TranscoderCommand.new("cmd", TranscoderCommand::SLOT_START, [])
      .validate.should eq("not enough arguments")
    end

    it "start slot - 1 argument" do
      TranscoderCommand.new("cmd", TranscoderCommand::SLOT_START, %w(source1))
      .validate.should eq("not enough arguments")
    end

    it "stop slot - no args" do
      TranscoderCommand.new("cmd", TranscoderCommand::SLOT_STOP, [])
      .validate.should eq("not enough arguments")
    end


  end

  describe "self#create" do

    it "is nil when blank" do
      TranscoderCommand.create(nil).should be_nil
      TranscoderCommand.create("").should be_nil
      TranscoderCommand.create("   ").should be_nil
    end

    it "is a correct save command" do
      command = TranscoderCommand.create("save    ")
      command.cmd.should eq("save    ")
      command.type.should eq(TranscoderCommand::TRANSCODER_SAVE)
      command.args.should be_empty
    end

    it "is a correct reset command" do
      command = TranscoderCommand.create(" rEsEt ")
      command.cmd.should eq(" rEsEt ")
      command.type.should eq(TranscoderCommand::TRANSCODER_RESET)
      command.args.should be_empty
    end

    it "is a correct status command" do
      command = TranscoderCommand.create(" Status ")
      command.cmd.should eq(" Status ")
      command.type.should eq(TranscoderCommand::TRANSCODER_STATUS)
      command.args.should be_empty
    end

    it "is a correct slot create command" do
      command = TranscoderCommand.create("slot create Preset1 11 20")
      command.cmd.should eq("slot create Preset1 11 20")
      command.type.should eq(TranscoderCommand::SLOT_CREATE)
      command.args.should eq(%w(Preset1 11 20))
    end

    it "is a correct slot start command" do
      command = TranscoderCommand.create("slot start 1")
      command.cmd.should eq("slot start 1")
      command.type.should eq(TranscoderCommand::SLOT_START)
      command.args.should eq(%w(1))
    end

    it "is a correct slot stop command" do
      command = TranscoderCommand.create("slot stop 12 20")
      command.cmd.should eq("slot stop 12 20")
      command.type.should eq(TranscoderCommand::SLOT_STOP)
      command.args.should eq(%w(12 20))
    end

    it "is a correct unknown command" do
      command = TranscoderCommand.create("some command")
      command.cmd.should eq("some command")
      command.type.should eq(TranscoderCommand::UNKNOWN_COMMAND)
      command.args.should be_empty
    end

    it "is a correct unknown slot command" do
      command = TranscoderCommand.create("slot command 12 12 13")
      command.cmd.should eq("slot command 12 12 13")
      command.type.should eq(TranscoderCommand::UNKNOWN_COMMAND)
      command.args.should be_empty
    end

  end

end
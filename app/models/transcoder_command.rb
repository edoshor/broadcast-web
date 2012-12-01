class TranscoderCommand

  # commands
  UNKNOWN_COMMAND = -1
  SLOT_CREATE = 1
  SLOT_DELETE = 2
  SLOT_START = 3
  SLOT_STOP = 4
  TRANSCODER_SAVE = 5
  TRANSCODER_RESET = 6

  # attributes
  attr_reader :cmd, :type, :args

  # constructors
  def initialize(cmd, type, args)
    @cmd = cmd
    @type = type
    @args = args
  end

  # public methods
  def validate
    case @type
      when SLOT_CREATE
        (@args.length > 1) ? "valid" : "not enough arguments"
      when SLOT_DELETE
        (not @args.empty?) ? "valid" : "not enough arguments"
      when SLOT_START
        (not @args.empty?) ? "valid" : "not enough arguments"
      when SLOT_STOP
        (not @args.empty?) ? "valid" : "not enough arguments"
      when TRANSCODER_SAVE, TRANSCODER_RESET
        "valid"
      else
        "unknown command"
    end
  end

  def to_s
    "Type: #@type Args: #@args"
  end

  # Class methods
  def self.create(command)
    return nil if command.blank?

    args = []
    tokens = command.split
    case tokens[0].downcase
      when "slot"
        case tokens[1]
          when "create"
            type = SLOT_CREATE
          when "delete"
            type = SLOT_DELETE
          when "start"
            type = SLOT_START
          when "stop"
            type = SLOT_STOP
          else
            type = UNKNOWN_COMMAND
        end
        args.concat tokens.slice(2,tokens.length) unless type == UNKNOWN_COMMAND
      when "save"
        type = TRANSCODER_SAVE
      when "reset"
        type = TRANSCODER_RESET
      else
        type = UNKNOWN_COMMAND
    end

    return TranscoderCommand.new(command, type, args)
  end
end
class TranscoderCommand

  # constants

  UNKNOWN_COMMAND = -1
  TRANSCODER_SAVE = 1
  TRANSCODER_RESET = 2
  TRANSCODER_STATUS = 3
  SLOT_CREATE = 4
  SLOT_DELETE = 5
  SLOT_START = 6
  SLOT_STOP = 7

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
        return 'not enough arguments' if @args.length < 2
        preset = @args[0].downcase
        return 'unknown preset' unless 'auto' == preset || GlobalConstants::PRESETS.has_key?(preset.to_sym)
        return 'invalid slot id' unless slot_ids_valid? @args.slice(1, @args.length)
        'valid'
      when SLOT_START
        return 'not enough arguments' if @args.length < 2
        return 'unknown source' unless GlobalConstants::SOURCES.has_key? @args[0].downcase.to_sym
        return 'invalid slot id' unless slot_ids_valid? @args.slice(1, @args.length)
        'valid'
      when SLOT_DELETE, SLOT_STOP
        return 'not enough arguments' if @args.empty?
        return 'invalid slot id' unless 'all' == @args[0].downcase || slot_ids_valid?(@args)
        'valid'
      when TRANSCODER_SAVE, TRANSCODER_RESET, TRANSCODER_STATUS
        'valid'
      else
        'unknown command'
    end
  end

  def execute(transcoder)
    raise ArgumentError, 'unknown command' if @type == UNKNOWN_COMMAND
    results = expand_commands.map {|cmd| cmd.execute transcoder }

    # logic for results handling goes here
  end

  def to_s
    "transcoder command type #@type args: #@args"
  end

  # private methods
  private

  def expand_commands
    case @type
      when SLOT_CREATE
        # TODO implement
      when SLOT_DELETE
        expand_ids.map {|id| TranscoderApiCommand.new(Transcoder::MOD_REMOVE_SLOT, {slot_id: id})}
      when SLOT_START
        # TODO implement
      when SLOT_STOP
        expand_ids.map {|id| TranscoderApiCommand.new(Transcoder::MOD_SLOT_CMD,
                                                      {slot_cmd: Transcoder::CMD_SLOT_STOP, slot_id: id})}
      when TRANSCODER_SAVE
        [TranscoderApiCommand.new(Transcoder::MOD_SAVE_CONFIG, {})]
      when TRANSCODER_RESET
        [TranscoderApiCommand.new(Transcoder::MOD_RESTART, {})]
      when TRANSCODER_STATUS
        [TranscoderApiCommand.new(Transcoder::MOD_GET_SLOTS, {})]
      else
    end
  end

  def expand_ids
    case @type
      when SLOT_CREATE, SLOT_START
        range = @args.slice(1, @args.length).map {|str| Integer(str)}
      when SLOT_DELETE, SLOT_STOP
        if 'all' == @args[0].downcase
          range = [0, 255]
        else
          range = args.map {|str| Integer(str)}
        end
      else
        return []
    end
    (range.length == 1) ? [range[0]] : range[0]..range[1]
  end

  def slot_ids_valid?(ids)
    ids.map {|id| Integer(id) rescue -1}.all? { |id| id.between?(0, 255)}
  end

  # Class methods
  def self.create(command)
    return nil if command.blank?

    args = []
    tokens = command.split
    case tokens[0].downcase
      when 'slot'
        case tokens[1]
          when 'create'
            type = SLOT_CREATE
          when 'delete'
            type = SLOT_DELETE
          when 'start'
            type = SLOT_START
          when 'stop'
            type = SLOT_STOP
          else
            type = UNKNOWN_COMMAND
        end
        args.concat tokens.slice(2,tokens.length) unless type == UNKNOWN_COMMAND
      when 'save'
        type = TRANSCODER_SAVE
      when 'reset'
        type = TRANSCODER_RESET
      when 'status'
        type = TRANSCODER_STATUS
      else
        type = UNKNOWN_COMMAND
    end

    return TranscoderCommand.new(command, type, args)
  end
end
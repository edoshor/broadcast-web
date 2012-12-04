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
  attr_accessor :transcoder_wrapper

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

  def execute(transcoder_wrapper)
    raise ArgumentError, 'unknown command' if @type == UNKNOWN_COMMAND
    @transcoder_wrapper = transcoder_wrapper
    results = expand_commands.map {|cmd| cmd.execute transcoder_wrapper.transcoder }

    # logic for results handling goes here
    all_ok = results.all? {|result| result[:error] == Transcoder::RET_OK rescue false}
    if all_ok
      success_message results
    else
      results.delete_if {|result| result[:error] == Transcoder::RET_OK}
    end
  end

  def to_s
    "transcoder command type #@type args: #@args"
  end

  # private methods
  private

  def expand_commands
    begin
      case @type
        when SLOT_CREATE
          expand_ids.map {|id|
            preset = get_preset
            @transcoder_wrapper.slots_presets[id] = preset[:id]
            TranscoderApiCommand.new(Transcoder::MOD_CREATE_SLOT,
                                     {slot_id: id}.merge!(preset)) }
        when SLOT_DELETE
          expand_ids.map {|id|
            @transcoder_wrapper.slots_presets.delete id
            TranscoderApiCommand.new(Transcoder::MOD_REMOVE_SLOT, {slot_id: id}) }
        when SLOT_START
          expand_ids.map {|id|
            TranscoderApiCommand.new(Transcoder::MOD_SLOT_CMD,
                                     {slot_cmd: Transcoder::CMD_SLOT_RESTART, slot_id: id}
                                     .merge!(get_source)
                                     .merge!(GlobalConstants::PRESETS_AUDIO_CHANNELS[@transcoder_wrapper.slots_presets[id]])) }
        when SLOT_STOP
          expand_ids.map {|id|
            @transcoder_wrapper.slots_presets.delete id
            TranscoderApiCommand.new(Transcoder::MOD_SLOT_CMD,
                                     {slot_cmd: Transcoder::CMD_SLOT_STOP, slot_id: id}) }
        when TRANSCODER_SAVE
          [TranscoderApiCommand.new(Transcoder::MOD_SAVE_CONFIG, {})]
        when TRANSCODER_RESET
          [TranscoderApiCommand.new(Transcoder::MOD_RESTART, {})]
        when TRANSCODER_STATUS
          current_slot_ids.map {|id|
            TranscoderApiCommand.new(Transcoder::MOD_SLOT_CMD,
                                     {slot_cmd: Transcoder::CMD_SLOT_GET_STATUS, slot_id: id}) }
        else
      end
    rescue Exception => e
      # Log exception backtrace here
      #logger.error e.backtrace
      raise 'Error creating transcoder api commands: ' + e.message
    end
  end

  def expand_ids
    case @type
      when SLOT_CREATE, SLOT_START
        range = @args.slice(1, @args.length).map {|str| Integer(str)}
      when SLOT_DELETE, SLOT_STOP
        if 'all' == @args[0].downcase
          return current_slot_ids
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

  def get_preset
    preset = @args[0].downcase
    if 'auto' == preset
      values = GlobalConstants::PRESETS.values
      values[rand(values.size)]
    else
      GlobalConstants::PRESETS[preset.gsub(/-/,'_').to_sym]
    end
  end

  def get_source
    GlobalConstants::SOURCES[@args[0].downcase.to_sym]
  end

  def current_slot_ids
    result = TranscoderApiCommand.new(Transcoder::MOD_GET_SLOTS, {}).execute @transcoder_wrapper.transcoder
    ids = result[:error] == Transcoder::RET_OK ? result[:result][:slots_ids] : nil
    ids.nil? ? [] : ids
  end

  def success_message(results)
    case @type
      when SLOT_CREATE
        'Slots created successfully'
      when SLOT_START
        expand_ids.map {|id| "http://#{@transcoder_wrapper.transcoder.host}:#{8000 + id}"}
      when SLOT_DELETE
        'Slots deleted successfully'
      when SLOT_STOP
        'Slots stopped successfully'
      when TRANSCODER_SAVE
        'Transcoder config saved successfully'
      when TRANSCODER_RESET
        'Transcoder reset successfully'
      when TRANSCODER_STATUS
        results.map {|result| result }
      else
        'success'
    end
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
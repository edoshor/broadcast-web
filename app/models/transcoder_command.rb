class TranscoderCommand

  # constants

  UNKNOWN_COMMAND = -1
  TRANSCODER_SAVE = 1
  TRANSCODER_RESTART = 2
  TRANSCODER_STATUS = 3
  SLOT_CREATE = 4
  SLOT_DELETE = 5
  SLOT_START = 6
  SLOT_STOP = 7
  MGMT_LOAD = 8
  MGMT_UNLOAD = 9


  # attributes

  attr_reader :cmd, :type, :args
  attr_accessor :transcoder

  # constructors

  def initialize(cmd, type, args)
    @cmd = cmd
    @type = type
    @args = args

    @manager = TranscoderManager.instance
  end

  # public methods

  def validate
    case @type
      when SLOT_CREATE
        return 'not enough arguments' if @args.length < 2
        preset = @args[0].downcase
        return 'unknown preset' unless 'auto' == preset || @manager.has_preset?(preset)
        return 'invalid slot id' unless slot_ids_valid? @args.slice(1, @args.length)
        'valid'
      when SLOT_START
        return 'not enough arguments' if @args.length < 2
        source1, source2, id_start, id_end = slot_start_args
        return 'unknown primary source' unless @manager.has_source? source1
        return 'unknown secondary source' unless source2.nil? || @manager.has_source?(source2)
        return 'invalid slot ids' unless slot_ids_valid?(id_end.nil? ? [id_start] : [id_start, id_end])
        'valid'
      when SLOT_DELETE, SLOT_STOP
        return 'not enough arguments' if @args.empty?
        return 'invalid slot id' unless 'all' == @args[0].downcase || slot_ids_valid?(@args)
        'valid'
      when MGMT_LOAD
        return 'not enough arguments' if @args.empty?
        return 'unknown source' unless @manager.has_source? @args[0].downcase
        'valid'
      when TRANSCODER_SAVE, TRANSCODER_RESTART, TRANSCODER_STATUS, MGMT_UNLOAD
        'valid'
      else
        'unknown command'
    end
  end

  def execute(transcoder)
    raise ArgumentError, 'unknown command' if @type == UNKNOWN_COMMAND

    @transcoder = transcoder

    results = expand_commands.map { |cmd| [cmd, cmd.execute(transcoder)] }
    all_ok = results.all? { |cmd, result| result[:error] == TranscoderApi::RET_OK rescue false }
    if all_ok
      {success: true, message: success_message}
    else
      results.delete_if { |cmd, result| result[:error] == TranscoderApi::RET_OK rescue true}
      {success: false, errors: results}
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
          expand_ids.map { |id|
            TranscoderApiCommand.new(TranscoderApi::MOD_CREATE_SLOT, {slot_id: id, preset: get_preset}) }
        when SLOT_DELETE
          expand_ids.map { |id|
            TranscoderApiCommand.new(TranscoderApi::MOD_REMOVE_SLOT, {slot_id: id}) }
        when SLOT_START
          primary_source, secondary_source = get_sources
          expand_ids.map { |id|
            TranscoderApiCommand.new(TranscoderApi::MOD_SLOT_CMD,
                                     {slot_cmd: TranscoderApi::CMD_SLOT_RESTART,
                                      slot_id: id,
                                      primary_source: primary_source,
                                      secondary_source: secondary_source}) }
        when SLOT_STOP
          expand_ids.map { |id|
            TranscoderApiCommand.new(TranscoderApi::MOD_SLOT_CMD,
                                     {slot_cmd: TranscoderApi::CMD_SLOT_STOP, slot_id: id}) }
        when TRANSCODER_SAVE
          [TranscoderApiCommand.new(TranscoderApi::MOD_SAVE_CONFIG, {})]
        when TRANSCODER_RESTART
          [TranscoderApiCommand.new(TranscoderApi::MOD_RESTART, {})]
        when TRANSCODER_STATUS
          []
        when MGMT_LOAD
          primary_source, secondary_source = get_sources
          [TranscoderMgmtCommand.new(TranscoderMgmtCommand::LOAD, {source: primary_source})]
        when MGMT_UNLOAD
          [TranscoderMgmtCommand.new(TranscoderMgmtCommand::UNLOAD, {})]
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
      when SLOT_CREATE
        range = @args.slice(1, @args.length).map { |str| Integer(str) }
      when SLOT_START
        source1, source2, id_start, id_end = slot_start_args
        range = id_end.nil? ? [id_start] : [id_start, id_end]
      when SLOT_DELETE, SLOT_STOP
        if 'all' == @args[0].downcase
          return @transcoder.current_slot_ids
        else
          range = args.map { |str| Integer(str) }
        end
      else
        return []
    end
    (range.length == 1) ? [range[0]] : range[0]..range[1]
  end

  def slot_ids_valid?(ids)
    ids.map { |id| Integer(id) rescue -1 }.all? { |id| id.between?(0, 255) }
  end

  def get_preset
    preset = @args[0].downcase
    'auto' == preset ? @manager.random_preset : @manager.get_preset(preset)
  end

  def get_sources
    if SLOT_START == @type
      source1, source2, id_start, id_end = slot_start_args
      src1 = @manager.get_source source1
      src2 = source2.nil? ? src1 : @manager.get_source(source2)
    else
      src1 = src2 = @manager.get_source @args[0].downcase
    end

    return src1, src2
  end

  def slot_start_args
    return [nil,nil,nil,nil] if @args.blank?

    source2 = id_start = id_end = nil
    source1 = @args[0].downcase
    begin
      id_start = Integer(@args[1])
      id_end = Integer(@args[2]) if @args.length > 2
    rescue
      source2 = @args[1].downcase
      id_start = Integer(@args[2]) if @args.length > 2
      id_end = Integer(@args[3]) if @args.length > 3
    end

    [source1, source2, id_start, id_end]
  end

  def success_message
    case @type
      when SLOT_CREATE
        'Slots created successfully'
      when SLOT_START
        'Slots started successfully'
      when SLOT_DELETE
        'Slots deleted successfully'
      when SLOT_STOP
        'Slots stopped successfully'
      when TRANSCODER_SAVE
        'Transcoder config saved successfully'
      when TRANSCODER_RESTART
        'Transcoder reset successfully'
      when MGMT_LOAD
        'Extra load on source successfully'
      when MGMT_UNLOAD
        'Extra load on source stopped successfully'
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
        args.concat tokens.slice(2, tokens.length) unless type == UNKNOWN_COMMAND
      when 'save'
        type = TRANSCODER_SAVE
      when 'restart'
        type = TRANSCODER_RESTART
      when 'status'
        type = TRANSCODER_STATUS
      when 'load'
        type = MGMT_LOAD
        args.concat tokens.slice(1, tokens.length)
      when 'unload'
        type = MGMT_UNLOAD
      else
        type = UNKNOWN_COMMAND
    end

    return TranscoderCommand.new(command, type, args)
  end
end
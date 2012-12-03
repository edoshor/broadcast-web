class TranscoderApiCommand

  # attributes

  attr_reader :type, :args

  # constructors

  def initialize(type, args)
    @type = type
    @args = args
  end

  # public methods

  def execute(transcoder)
    case @type
    when Transcoder::MOD_GET_SLOTS
      transcoder.mod_get_slots
      when Transcoder::MOD_GET_NET_CONFIG
        transcoder.mod_get_net_config @args[:slot_id]
      when Transcoder::MOD_SET_NET_CONFIG
        raise 'MOD_SET_NET_CONFIG not implemented'
      when Transcoder::MOD_RESTART
        transcoder.mod_restart
      when Transcoder::MOD_CREATE_SLOT
        transcoder.mod_create_slot(@args[:slot_id], @args[:force], @args[:tracks_cnt], @args[:tracks])
      when Transcoder::MOD_REMOVE_SLOT
        transcoder.mod_remove_slot @args[:slot_id]
      when Transcoder::MOD_GET_SLOT
        transcoder.mod_get_slot @args[:slot_id]
      when Transcoder::MOD_SAVE_CONFIG
        transcoder.mode_save_config
      when Transcoder::MOD_SLOT_CMD
        case @args[:slot_cmd]
      when Transcoder::CMD_SLOT_GET_STATUS
        transcoder.mod_slot_get_status @args[:slot_id]
          when Transcoder::CMD_SLOT_STOP
            transcoder.mod_slot_stop @args[:slot_id]
          when Transcoder::CMD_SLOT_RESTART
            transcoder.mod_slot_restart @args[:slot_id], @args[:ip1], @args[:port1], @args[:ip2], @args[:port2],
            @args[:tracks_cnt], @args[:tracks]
          else
            raise ArgumentError, 'unknown api slot command'
        end
      else
        raise ArgumentError, 'unknown api command'
    end
  end

  def to_s
    "transcoder API command type #@type args: #@args"
  end
end
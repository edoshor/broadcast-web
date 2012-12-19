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
    api = transcoder.api

    case @type
      when TranscoderApi::MOD_GET_SLOTS
        api.mod_get_slots
      when TranscoderApi::MOD_GET_NET_CONFIG
        api.mod_get_net_config @args[:slot_id]
      when TranscoderApi::MOD_SET_NET_CONFIG
        raise 'MOD_SET_NET_CONFIG not implemented'
      when TranscoderApi::MOD_RESTART
        api.mod_restart
      when TranscoderApi::MOD_CREATE_SLOT
        preset = @args[:preset]
        preset_args = preset.as_args
        ret = api.mod_create_slot(@args[:slot_id], preset_args[:force], preset_args[:tracks_cnt], preset_args[:tracks])
        transcoder.create_slot(@args[:slot_id], preset)
        ret
      when TranscoderApi::MOD_REMOVE_SLOT
        ret = api.mod_remove_slot @args[:slot_id]
        transcoder.remove_slot @args[:slot_id]
        ret
      when TranscoderApi::MOD_GET_SLOT
        api.mod_get_slot @args[:slot_id]
      when TranscoderApi::MOD_SAVE_CONFIG
        api.mode_save_config
      when TranscoderApi::MOD_SLOT_CMD
        case @args[:slot_cmd]
          when TranscoderApi::CMD_SLOT_GET_STATUS
            api.mod_slot_get_status @args[:slot_id]
          when TranscoderApi::CMD_SLOT_STOP
            api.mod_slot_stop @args[:slot_id]
          when TranscoderApi::CMD_SLOT_RESTART
            s1 = @args[:primary_source]
            s2 = @args[:secondary_source]
            tracks = transcoder.slot_preset(@args[:slot_id]).audio_mappings
            api.mod_slot_restart @args[:slot_id], s1.ip, s1.port, s2.ip, s2.port, tracks.length, tracks
          else
            raise ArgumentError, 'unknown api slot command'
        end
      else
        raise ArgumentError, 'unknown api command'
    end
  end

  def to_s
    "#{display_name}: #@args"
  end

  def display_name
    case @type
      when TranscoderApi::MOD_GET_SLOTS
        'get slots'
      when TranscoderApi::MOD_GET_NET_CONFIG
        'get network configuration'
      when TranscoderApi::MOD_SET_NET_CONFIG
        'set network configuration'
      when TranscoderApi::MOD_RESTART
        'restart'
      when TranscoderApi::MOD_SAVE_CONFIG
        'save configuration'
      when TranscoderApi::MOD_CREATE_SLOT
        'create slot'
      when TranscoderApi::MOD_REMOVE_SLOT
        'remove slot'
      when TranscoderApi::MOD_GET_SLOT
        'get slot info'
      when TranscoderApi::MOD_SLOT_CMD
        case @args[:slot_cmd]
          when TranscoderApi::CMD_SLOT_GET_STATUS
            'get slot status'
          when TranscoderApi::CMD_SLOT_STOP
            'stop slot'
          when TranscoderApi::CMD_SLOT_RESTART
            'start slot'
          else
            'unknown slot command'
        end
      else
        'unknown command'
    end
  end
end
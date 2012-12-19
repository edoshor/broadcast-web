class StubTranscoderApi

  # Board errors
  RET_OK = 1
  RET_ERROR = 2
  RET_EFORMAT = 3
  RET_EVALUE = 4
  RET_ERES = 5

  @@slots = {}

  attr_reader :host, :port, :debug

  def initialize(options, &block)
    @host = options.delete(:host)
    @port = options.delete(:port)
    @debug = options.delete(:debug)
    @timeout = 5
    @results = []

  end

  def mod_get_slots
    {func: 'mod_get_slots',
     error: RET_OK,
     message: get_error(RET_OK),
     command: 'command',
     response: 'response',
     result: {slots_cnt: @@slots.size, slots_ids: @@slots.keys}}
  end

  def mode_save_config
    {func: 'mode_save_config',
     error: RET_OK,
     message: get_error(RET_OK),
     command: 'command',
     response: 'response'}
  end

  def mod_restart
    {func: 'mod_restart',
     error: RET_OK,
     message: get_error(RET_OK),
     command: 'command',
     response: 'response'}
  end

  def mod_create_slot(slot_id, force, tracks_cnt, tracks)
    @@slots.store(slot_id, {force: force, tracks_cnt: tracks_cnt, tracks: tracks})

    {func: 'mod_create_slot',
     error: RET_OK,
     message: "Slot #{slot_id} was created",
     command: 'command',
     response: 'response'}
  end

  def mod_remove_slot(slot_id)
    error = (@@slots.has_key? slot_id) ? RET_OK : RET_ERROR
    @@slots.delete(slot_id) if RET_OK == error

    {func: 'mod_remove_slot',
     error: error,
     message: (RET_OK == error) ? "Slot #{slot_id} was removed" : get_error(error),
     command: 'command',
     response: 'response'}
  end

  def mod_get_slot(slot_id)
    slot = @@slots[slot_id]
    error = slot.nil? ? RET_ERROR : RET_OK
    ret = {func: 'mod_get_slot', error: error, message: get_error(response_code), command: 'command', response: 'response'}

    ret[:result] = {force: slot[:force], total_tracks: slot[:tracks_cnt], tracks: slot[:tracks]} if RET_OK == error

    ret
  end

  def mod_slot_get_status(slot_id)
    slot = @@slots[slot_id]
    error = slot.nil? ? RET_ERROR : RET_OK
    ret = {func: 'mod_slot_get_status', error: error, command: 'command', response: 'response'}

    if RET_OK == error
      if slot[:source].nil?
        ret[:message] = "Slot is stopped"
      else
        ret[:message] = "Slot is running"
        ret[:result] = slot.merge({signal: 'signal', uptime: (Time.now - slot[:source][:start_time]).to_i})
      end
    else
      ret[:message] = get_error(error)
    end

    ret
  end

  def mod_slot_stop(slot_id)
    slot = @@slots[slot_id]
    error = slot.nil? ? RET_ERROR : RET_OK
    slot.delete(:source) if RET_OK == error

    {func: 'mod_slot_stop',
     error: error,
     message: error == RET_OK ? "Slot #{slot_id} was stopped" : "Slot #{slot_id} was NOT stopped",
     command: 'command',
     response: 'response'}
  end

  def mod_slot_restart(slot_id, ip1, port1, ip2, port2, tracks_cnt, tracks)
    slot = @@slots[slot_id]
    error = slot.nil? ? RET_ERROR : RET_OK
    if RET_OK == error
      slot.store(:source, {start_time: Time.now,
                           ip1: ip1, port1: port1, ip2: ip2, port2: port2,
                           tracks_cnt: tracks_cnt, tracks: tracks})
    end

    {func: 'mod_slot_restart',
     error: error,
     message: error == RET_OK ? "Slot #{slot_id} was (re)started" : "Slot #{slot_id} was NOT (re)started",
     command: 'command',
     response: 'response'}
  end

  private

  def get_error(error_code, message = nil)
    case error_code
      when RET_OK
        'Command completed successfully'
      when RET_ERROR
        'Internal error when processing command'
      when RET_EFORMAT
        'Bad format of request message'
      when RET_EVALUE
        'Bad value of some parameter in request message'
      when RET_ERES
        'Not enough resources to create slot'
      else
        message
    end
  end

end